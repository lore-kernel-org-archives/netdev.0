From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP connection will hang in FIN_WAIT1 after closing if zero
 window is advertised
Date: Tue, 16 Sep 2014 06:09:26 -0700
Message-ID: <1410872966.7106.187.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54170FC0.6020907@oktetlabs.ru>
	 <1410822949.5018.4.camel@localhost> <54183150.5030400@oktetlabs.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>,
	Konstantin Ushakov <kostik@oktetlabs.ru>
To: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:41805 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753863AbaIPNJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 09:09:28 -0400
Received: by mail-pa0-f46.google.com with SMTP id kq14so8811671pab.33
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 06:09:27 -0700 (PDT)
In-Reply-To: <54183150.5030400@oktetlabs.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-16 at 16:47 +0400, Andrey Dmitrov wrote:
> On 16/09/14 03:15, Hannes Frederic Sowa wrote:
> > Also thanks for the report.
> >
> > Do you see any tcp window repair messages in dmesg? Can you send some
> > output of ss -oemit state FIN-WAIT-1 from the target host?
> Hannes,
> no, there aren't any messages in dmesg until net.ipv4.tcp_max_orphans is 
> achieved.


Andrey, you should take a look at Labrea Tarpit,

http://www.sans.org/reading-room/whitepapers/casestudies/smart-ids-hybrid-labrea-tarpit-33254

What happens is the following :

A normal TCP session is established, traffic is sent from server to
client.

Client sends a zero window.

1) This can be normal, because application reading client queue no
longer can. (For example its a ssh session, and output to the terminal
is blocked by CTRL S). There are valid cases when you block this for
many hours.

2) This can be faked by malicious peer, willing to make server enter
this mode (inability to send more data, data stack in output queue, one
probe sent every RTO). This is a very well known way to let servers
consume a lot of kernel memory and eventually OOM.


Then server sends a probe every RTO, and client responds with a ACK with
win=0

TCP specs say : This can last forever, even if socket is eventually
closed by the server (because he gave up) and enters FIN_WAIT

Supposedly, if a server is about to give up, it might tell the TCP
stack : Oh, do not bother absolutely sending the remaining bytes you
have in output queue (I, the application, already waited for a very
reasonable time)

Normally SO_LINGER could be used, or TCP_USER_TIMEOUT. This requires a
system call before doing the close().

1) TCP_USER_TIMEOUT would be the fit for this, but its current
implementation do not take care of the probes sent, even in FIN_WAIT
state when in this zero window mode. A patch would be needed.

2) SO_LINGER, timeout=0 might work.
