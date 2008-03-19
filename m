From: "Benjamin Thery" <ben.thery@gmail.com>
Subject: Re: [2.6.25-rc5-mm1] regression: cannot run Postfix sendmail command as non-root
Date: Wed, 19 Mar 2008 18:52:41 +0100
Message-ID: <939d53060803191052o2f43b75cu426d51f9f24e2a46@mail.gmail.com>
References: <20080311011434.ad8c8d7d.akpm@linux-foundation.org>
	 <47D98510.60801@imap.cc>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_18122_28960756.1205949161815"
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David Miller" <davem@davemloft.net>, pekkas@netcore.fi,
	yoshfuji@linux-ipv6.org, "Daniel Lezcano" <dlezcano@fr.ibm.com>,
	"Pavel Emelyanov" <xemul@openvz.org>
To: "Tilman Schmidt" <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.231]:12444 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753054AbYCSTjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 15:39:32 -0400
Received: by wr-out-0506.google.com with SMTP id c48so524912wra.1
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2008 12:39:29 -0700 (PDT)
In-Reply-To: <47D98510.60801@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_18122_28960756.1205949161815
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Tilman,

I've finally managed to reproduce your problem with Postfix on one of
my victims.

Earlier, in the afternoon, I wrote a piece of code that triggered a
similar behaviour,
but I wasn't sure it was exactly the problem you found. So, I've
rebuilt Postfix, added
some traces and, voila, same issue as yours.
(The version of Postfix originally  installed on my machine seems to
have IPv6 disabled)

I bisected the problem to the commit "[NET]: Make /proc/net a symlink
on /proc/self/net (v3)"

Here is what happens:

- Recently /proc/net has been moved to /proc/self/net, and
/proc/self/net is a symlink
  on this directory.
- Before that everybody could access /proc/net and read /proc/net/if_inet6:
   dr-xr-xr-x   6 root      root              0 2008-03-05 15:23 /proc/net

- Now, /proc/self/net has a more restrictive access mode and ony the
owner of the
  process can enter the directory:
  dr-xr--r-- 5 toto toto 0 Mar 19 17:30 net

  This is not a problem in most of the cases, but it becomes annoying
when a process
  decides to change its UID or GID. It may loose access to its own
/proc/self/net entries.

- What happens in the Postfix case is the 'sendmail' process executes the
   '/usr/sbin/postdrop' binary to enqueue the message, but unfortunately
   '/usr/bin/postdrop' has the setgid bit set:
   -rwxr-sr-x 1 root postdrop 479475 Mar 19 17:14 /usr/sbin/postdrop

   The process egid changes and this seems to be problematic to access
   /proc/self/net/if_inet6. :)

I've attached a tiny test program that can be used to reproduce the problem
without Postfix.
- Either execute it as root and give it an unprivileged uid in argument
  ./test-proc_net_if_inet6 1001

- Or change its ownership and access mode to: -rwxr-sr-x root postdrop
  and execute it as a lambda user.
   chown root:postdrop test-proc_net_if_inet6; chmod 2755 test-proc_net_if_=
inet6
   ./test-proc_net_if_inet6

I've found the cause but not the fix. :)
(Adding Pavel in cc:)

Regards,
Benjamin


On Thu, Mar 13, 2008 at 8:48 PM, Tilman Schmidt <tilman@imap.cc> wrote:
> Am 11.03.2008 09:14 schrieb Andrew Morton:
>  > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.25-r=
c5/2.6.25-rc5-mm1/
>
>  I'm noticing a strange effect with this:
>
>  On my openSUSE 10.3 development machine with SUSEs default MTA
>  Postfix installed, I occasionally send a pre-formatted mail by
>  feeding it directly into "/usr/sbin/sendmail -t". If I try that
>  while running a 2.6.25-rc5-mm1 kernel, I get:
>
>  ts@xenon:~/kernel> /usr/sbin/sendmail -t < patch-usb-reduce-syslog-clutt=
er-v3
>  postdrop: warning: can't open /proc/net/if_inet6 (Permission denied) - s=
kipping IPv6 configuration
>  postdrop: fatal: parameter inet_interfaces: no local interface found for=
 ::1
>  sendmail: warning: command "/usr/sbin/postdrop -r" exited with status 1
>  sendmail: fatal: ts(1000): unable to execute /usr/sbin/postdrop -r: Succ=
ess
>  ts@xenon:~/kernel>
>
>  and unsurprisingly, the mail is not sent. If I do the same as root,
>  everything works as usual, there is no console output from the
>  sendmail command, and the mail goes out as it should. All other
>  networking applications appear to be running normally.
>
>  On a 2.6.25-rc5 (non-mm) kernel I do not need to run the sendmail
>  command as root. It works just as well if I run it as myself.
>
>  IPv6 is not in use on that machine. The Ethernet interface has
>  just the link local IPv6 address. Possibly relevant information:
>
>  ts@xenon:~> /sbin/ifconfig -a
>  eth0      Protokoll:Ethernet  Hardware Adresse 00:19:D1:03:D8:FF
>           inet Adresse:192.168.59.102  Bcast:192.168.59.255  Maske:255.25=
5.255.0
>           inet6 Adresse: fe80::219:d1ff:fe03:d8ff/64 G=FCltigkeitsbereich=
:Verbindung
>           UP BROADCAST NOTRAILERS RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:78 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:145 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 Sendewarteschlangenl=E4nge:100
>           RX bytes:9547 (9.3 Kb)  TX bytes:17952 (17.5 Kb)
>           Speicher:92c00000-92c20000
>
>  lo        Protokoll:Lokale Schleife
>           inet Adresse:127.0.0.1  Maske:255.0.0.0
>           inet6 Adresse: ::1/128 G=FCltigkeitsbereich:Maschine
>           UP LOOPBACK RUNNING  MTU:16436  Metric:1
>           RX packets:2 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:2 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 Sendewarteschlangenl=E4nge:0
>           RX bytes:100 (100.0 b)  TX bytes:100 (100.0 b)
>
>  ts@xenon:~/kernel> ls -l /proc/net/if_inet6
>  -r--r--r-- 1 root root 0 13. M=E4r 19:26 /proc/net/if_inet6
>  ts@xenon:~> cat /proc/net/if_inet6
>  fe800000000000000219d1fffe03d8ff 02 40 20 80     eth0
>  00000000000000000000000000000001 01 80 10 80       lo
>  ts@xenon:~> uname -a
>  Linux xenon 2.6.25-rc5-mm1-testing #1 SMP PREEMPT Tue Mar 11 14:34:49 CE=
T 2008 i686 i686 i386 GNU/Linux
>
>  As you see, I can cat /proc/net/if_inet6 as regular (non-root) user
>  just fine, even though Postfix complains it cannot access it.
>  The content of /proc/net/if_inet6 is identical if I cat it on
>  kernel 2.6.25-rc5 mainline.
>
>  CCing a selection of IPv6 networking related maintainer addresses.
>  If you need more information or want me to test something, let me
>  know.
>
>  HTH
>  T.
>
>  --
>  Tilman Schmidt                          E-Mail: tilman@imap.cc
>  Bonn, Germany
>  Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
>  Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)
>
>

------=_Part_18122_28960756.1205949161815
Content-Type: text/x-csrc; name=test-proc_net_if_inet6.c
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fe06wffg0
Content-Disposition: attachment; filename=test-proc_net_if_inet6.c

I2luY2x1ZGUgPHN0ZGlvLmg+CiNpbmNsdWRlIDxzdGRsaWIuaD4KI2luY2x1ZGUgPHVuaXN0ZC5o
PgoKaW50IG1haW4oaW50IGFyZ2MsIGNoYXIgKmFyZ3ZbXSkKewoJRklMRSAqZnA7Cgl1aWRfdCB1
aWQ7CgoJaWYgKGFyZ2MgPiAxKSB7CgkJdWlkID0gYXRvaShhcmd2WzFdKTsKCQlpZiAoc2V0dWlk
KHVpZCkgPCAwKSB7CgkJCXBlcnJvcigic2V0dWlkIik7CgkJCXJldHVybiAxOwoJCX0KCX0KCglw
cmludGYoIlBJRD0lZCBVSUQ9JWQgR0lEPSVkXG4iLCBnZXRwaWQoKSwgZ2V0ZXVpZCgpLCBnZXRl
Z2lkKCkpOwoKCWlmICgoZnAgPSBmb3BlbigiL3Byb2MvbmV0L2lmX2luZXQ2IiwgInIiKSkgIT0g
MCkgewoJCXByaW50ZigiUEFTUzogL3Byb2MvbmV0L2lmX2luZXQ2IG9wZW5lZFxuIik7CgkJZmNs
b3NlKGZwKTsKCX0gZWxzZSB7CgkJcHJpbnRmKCJGQUlMOiBDYW4ndCBvcGVuIC9wcm9jL25ldC9p
Zl9pbmV0NlxuIik7CgkJcmV0dXJuIDE7Cgl9CglyZXR1cm4gMDsKfQo=
------=_Part_18122_28960756.1205949161815--
