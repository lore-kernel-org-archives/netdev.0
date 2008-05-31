From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Sat, 31 May 2008 13:05:26 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805311044360.2189@wrl-59.cs.helsinki.fi>
References: <48402BD7.2080705@madrabbit.org> <Pine.LNX.4.64.0805302105170.1761@wrl-59.cs.helsinki.fi>
 <20080531060315.GA2692@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1952734284-1212220106=:2189"
Cc: Ray Lee <ray-lk@madrabbit.org>, Ingo Molnar <mingo@elte.hu>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35542 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566AbYEaKFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2008 06:05:30 -0400
In-Reply-To: <20080531060315.GA2692@2ka.mipt.ru>
Content-ID: <Pine.LNX.4.64.0805311216230.2329@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1952734284-1212220106=:2189
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0805311048491.2189@wrl-59.cs.helsinki.fi>

On Sat, 31 May 2008, Evgeniy Polyakov wrote:

> On Sat, May 31, 2008 at 12:11:32AM +0300, Ilpo Järvinen (ilpo.jarvinen@helsinki.fi) wrote:
> > > > > Active Internet connections (w/o servers)
> > > > > Proto Recv-Q Send-Q Local Address               Foreign Address
> > > > > State
> > > > > tcp        0 174592 10.0.1.14:58015             10.0.1.14:3632  ESTABLISHED
> > > > > tcp    72134      0 10.0.1.14:3632              10.0.1.14:58015 ESTABLISHED
> > 
> >              ^^^^^
> > 
> > Can you perhaps find/guess/think some explanation for this _receiver 
> > queue_...? This was a trick question :-), as we already know that the 
> > receiving process is no longer there and therefore obviously won't be 
> > reading anything anymore. But that opened another question, why TCP is 
> > then still in ESTABLISHED as orphaned TCP shouldn't be in establised state 
> > anymore, tcp_close should have changed the state (either at close or at 
> > process exit). I guess once it becomes known why tcp_close either wasn't 
> > called at all or it didn't change the state of the flow (it's quite 
> > simple, see for yourself), the cause of the bug is found (it might even be 
> > that the process went away when it shouldn't have, either a bookkeeping 
> > bug somewhere or real death, or something along those lines).
> 
> In that case pid Ingo straced was still valid and existed (ans stuck
> probably in tcp_sendpage() - sysrq-t dump was messy),

...No, I think it was the sender, not the receiver that Ingo straced!
A _correctly_ behaving TCP sender will just get "stuck" once the window
is exhausted. It as was proven that advertized window is zero (tcpdump).
So I find that hardly a bug.

> so process still exist, but sock somewhat lost its reference to socket.

...this is something that seems possible explanation.

> AFICS all (three)
> calls for sk_orphan() can not happen without state change to something
> closing (like fin wait or close), except some linger things and
> listening socket, which frees its connection requests.

Yes, this what I figured out as well (distcc didn't seem to play with 
linger, I checked, nor would it have any reason to)... The LISTENING 
socket was still there in /proc/net/tcp, so closing that won't explain it.

In addition, it seems that tcp_close would notify the other end as well, 
either with RST or with FIN, which would cause the other end to leave 
ESTABLISHED (unless tcp_transmit_skb would fail but I guess that would end 
up into some MIB in either of the cases). Here RST is the way to go 
because there's unread data (though in theory having yet another bug could 
allow building up the receiver queue afterwards).

Which then boils down to two alternatives:
  1) The receiving process lost its reference though the process 
     still exists and therefore cannot read
  2) tcp_close wasn't called when it should have, e.g., process exited
     but the tcp_close wasn't called because the reference wasn't there

Btw, Ingo also got this warning later on which might be helpful in 
understanding all this:

>>>>> after ~7 hours of uptime the networking code produced this assertion:
>>>>>
>>>>> [25441.140000] KERNEL: assertion (!sk->sk_ack_backlog) failed at 
>>>>>  net/ipv4/inet_connection_sock.c (642)

I guess that sk_ack_backlog was already visible at the time when the TCP 
got stuck because listening socket already had 1 there in /proc/net/tcp 
(though this depends if there was some other connection attempts still 
going on).


...Some new info (at least to me). I tried with ./stress_accept 5000 2 
(attached), I could easily produce a number of ESTABLISHED connections 
which won't yet have an owner in netstat (tested in 2.6.25.3) while 
connect.sh is running but it seems some kind of transitional state as once 
I do killall -TERM connect.sh (attached), they get the owning 
stress_accept. So third explanation would be some race during that 
transition that would allow process to never get the reference...

Before:
tcp    65436      0 lo:5000          lo:59980         ESTABLISHED -
After killall:
tcp    76444      0 lo:5000          lo:59980         ESTABLISHED 9013/stress_accept


-- 
 i.
---696208474-1952734284-1212220106=:2189
Content-Type: TEXT/PLAIN; charset=US-ASCII; name=stress_accept.c
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.64.0805311305260.2329@wrl-59.cs.helsinki.fi>
Content-Description: 
Content-Disposition: attachment; filename=stress_accept.c

I2luY2x1ZGUgPHN0ZGlvLmg+DQojaW5jbHVkZSA8c3RkbGliLmg+DQojaW5j
bHVkZSA8c3RyaW5nLmg+DQoNCiNpbmNsdWRlIDx1bmlzdGQuaD4NCiNpbmNs
dWRlIDxzeXMvd2FpdC5oPg0KDQojaW5jbHVkZSA8c3lzL3R5cGVzLmg+DQoj
aW5jbHVkZSA8c3lzL3NvY2tldC5oPg0KI2luY2x1ZGUgPG5ldGluZXQvaW4u
aD4NCiNpbmNsdWRlIDxhcnBhL2luZXQuaD4NCg0KDQp2b2lkIGVycm9yKGNv
bnN0IGNoYXIgKnN0cikNCnsNCglwZXJyb3Ioc3RyKTsNCglleGl0KDEpOw0K
fQ0KDQp2b2lkIHdvcmtlcihpbnQgbGlzdGVuZmQpDQp7DQoJaW50IGZkOw0K
CXN0cnVjdCBzb2NrYWRkcl9pbiBwZWVyYWRkcjsNCglzb2NrbGVuX3QgbGVu
ID0gc2l6ZW9mKHBlZXJhZGRyKTsNCglpbnQgcGlkOw0KCWNoYXIgYnVmWzEw
MF07DQoNCgl3aGlsZSgxKSB7DQoJCW1lbXNldCgmcGVlcmFkZHIsIDAsIHNp
emVvZihwZWVyYWRkcikpOw0KCQlmZCA9IGFjY2VwdChsaXN0ZW5mZCwgKHN0
cnVjdCBzb2NrYWRkciAqKSZwZWVyYWRkciwgJmxlbik7DQoJCWlmIChmZCA8
IDApDQoJCQllcnJvcigiYWNjZXB0Iik7DQoNCgkJcGlkID0gZm9yaygpOw0K
CQlpZiAocGlkIDwgMCkgew0KCQkJZXJyb3IoImZvcmsiKTsNCgkJfSBlbHNl
IGlmIChwaWQgIT0gMCkgew0KCQkJY2xvc2UoZmQpOw0KLyoJCQl3aGlsZSgx
KQ0KCQkJCXNsZWVwKDEpOyAqLw0KCQl9IGVsc2Ugew0KCQkJcmVhZChmZCwg
JmJ1Ziwgc2l6ZW9mKGJ1ZikpOw0KCQkJd2hpbGUoMSkNCgkJCQlzbGVlcCgx
KTsNCgkJCWV4aXQoMCk7DQoJCX0NCgl9DQoNCglleGl0KDApOw0KfQ0KDQpp
bnQgbWFpbihpbnQgYXJnYywgY2hhciAqKmFyZ3YpDQp7DQoJaW50IGxpc3Rl
bmZkOw0KCXN0cnVjdCBzb2NrYWRkcl9pbiBteWFkZHI7DQoJaW50IHJlczsN
CglwaWRfdCBwaWQ7DQoJaW50IGk7DQoNCglpZiAoYXJnYyA8IDMpIHsNCgkJ
ZnByaW50ZihzdGRlcnIsICIlcyBzZXJ2ZXJwb3J0IHByb2Nlc3Nlc1xuIiwg
YXJndlswXSk7DQoJCWV4aXQoMSk7DQoJfQ0KCQ0KCWxpc3RlbmZkID0gc29j
a2V0KFBGX0lORVQsIFNPQ0tfU1RSRUFNLCAwKTsNCglpZiAobGlzdGVuZmQg
PCAwKQ0KCQllcnJvcigic29ja2V0Iik7DQoJDQoJbWVtc2V0KCZteWFkZHIs
IDAsIHNpemVvZihteWFkZHIpKTsNCglteWFkZHIuc2luX2ZhbWlseSA9IFBG
X0lORVQ7DQoJbXlhZGRyLnNpbl9hZGRyLnNfYWRkciA9IGluZXRfYWRkcigi
MTI3LjAuMC4xIik7DQoJbXlhZGRyLnNpbl9wb3J0ID0gaHRvbnMoYXRvaShh
cmd2WzFdKSk7DQogICAgDQoJcmVzID0gYmluZChsaXN0ZW5mZCwgKHN0cnVj
dCBzb2NrYWRkciAqKSZteWFkZHIsIHNpemVvZihteWFkZHIpKTsNCglpZiAo
cmVzIDwgMCkNCgkJZXJyb3IoImJpbmQiKTsNCg0KCS8qIGRpc3RjY2QgdXNl
cyAxMCBoZXJlICovDQoJaWYgKGxpc3RlbihsaXN0ZW5mZCwgMTApIDwgMCkN
CgkJZXJyb3IoImxpc3RlbiIpOw0KDQoJZm9yIChpID0gMDsgaSA8IGF0b2ko
YXJndlsyXSk7IGkrKykgew0KCQlwaWQgPSBmb3JrKCk7DQoJCWlmIChwaWQg
PCAwKQ0KCQkJZXJyb3IoImZvcmsiKTsNCg0KCQlpZiAocGlkID09IDApIHsN
CgkJCXdvcmtlcihsaXN0ZW5mZCk7DQoJCX0NCgl9DQoNCgl3aGlsZSAoMSkg
ew0KCQlzbGVlcCgxKTsNCgl9DQoNCglyZXR1cm4gMDsNCn0NCg==

---696208474-1952734284-1212220106=:2189
Content-Type: APPLICATION/x-sh; name=connect.sh
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.64.0805311305261.2329@wrl-59.cs.helsinki.fi>
Content-Description: 
Content-Disposition: attachment; filename=connect.sh

IyEvYmluL3NoCgp3aGlsZSBbIDogXTsgZG8KCW5jIGxvY2FsaG9zdCA1MDAw
IDwgL2Rldi96ZXJvICYKCWRpc293bgoJc2xlZXAgMC4wNQpkb25lCg==

---696208474-1952734284-1212220106=:2189--
