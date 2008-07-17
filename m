From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Thu, 17 Jul 2008 18:53:01 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0807171819160.13775@wrl-59.cs.helsinki.fi>
References: <47EA0DAB.7080205@securenet.de> <200807161103.07821.thomas.jarosch@intra2net.com>
 <Pine.LNX.4.64.0807171537560.13775@wrl-59.cs.helsinki.fi>
 <200807171715.16265.thomas.jarosch@intra2net.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-529547943-1216309981=:13775"
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	"=?ISO-8859-1?Q?D=E2niel_Fraga?=" <fragabr@gmail.com>,
	David Miller <davem@davemloft.net>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50806 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756674AbYGQPxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 11:53:19 -0400
In-Reply-To: <200807171715.16265.thomas.jarosch@intra2net.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-529547943-1216309981=:13775
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 17 Jul 2008, Thomas Jarosch wrote:

> On Thursday, 17. July 2008 15:55:25 Ilpo Järvinen wrote:
> > It would quite interesting to know more details about the mail server and
> > why the duplicate ACKs are not generated or don't ever reach the sender
> > but I guess the details are out of reach?
> 
> It will be quite difficult to get more details as it's the SMTP relay sever
> of Germany's biggest ISP. There's a comment about them
> in Patrick's blog from 2008-06-23 if you are curious ;-)

...I thought so, unless one has some connections they're not that
willing, ever :-).

> We see the same issue with a MX server from "United Internet".
> Normally they are pretty accurate about standards (they run GMX),
> so I guess this must be a problem of a router in between.

I'd vote for middlebox, e.g., some kind of TCP proxy, split TCP 
brokeness or misconfigured firewall or such (or perhaps it's just
because of some misguided one who have been thought that duplicate
ACKs are a serious threat :-))...

> Could you somehow "probe" the servers to see if they normally
> send duplicated ACKs by faking/forcing a retransmission?
> Though I guess this would invole writing some TCP "test" code.

Yes, it wouldn't even be that hard to do with hping3. I might actually 
try to come up with something (but not now).

> > One option would be to disable reentry to FRTO when some progress was
> > made... Please try with the patch below...
> 
> Thanks for the patch. It seemed to help a bit. Here are two more traces:
> http://www.intra2net.com/de/download/tcpdump/tcp_frto_with_patch.tar.bz2
> 
> The first connection somehow made it after 400 seconds,
> the second one stalled and timed out :-(
> Hope they dumps are useful to you.

Ah, I just forgot that the situation might persist... Try with this 
one instead...

-- 
 i.

[PATCH] tcp FRTO: workaround dupACK-less receivers

FRTO assumes that dupACKs arrive in-order to fallback into
conventional recovery. Some receivers, due to unknown reasons,
care not to send duplicate ACKs at all, which seems quite
unreasonable because RFC2581 is using SHOULD for ofo segment
duplicate ACKs. ...A more likely cause might be some broken
middlebox which blocks dupACKs. If no duplicate ACKs arrive,
TCP goes into RTO-loop due to FRTO, because only new data is
getting sent after the retransmission of the head segment
(and its partial ACK). The situation continues until a big
cumulative ACK covers all outstanding data (or until somebody
gives up).

The new approach prevents reentry to FRTO when a previous FRTO
recovery is underway. This alone was found inadequate solution
because the situation may persist with some receivers even after
the first fallback has occured. Thus cover anything in CA_Loss
state too.

This impacts FRTO accuracy as we lose ability to detect more than
one spurious segment per window with NewReno. Performance impact
in real world is hard to estimate because it's hard to know how
often second RTO would be spurious in practice, however, the
worst case behavior will still be as without FRTO so it just
reduces the benefits of FRTO.

This issue was reported by Thomas Jarosch and probably a number
of other people (though there was other case which was a real
bug with similar symptoms that was fixed in 2.6.25.7).

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
Reported-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/ipv4/tcp_input.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d6ea970..764c084 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1714,6 +1714,10 @@ int tcp_use_frto(struct sock *sk)
 	if (tcp_is_sackfrto(tp))
 		return 1;
 
+	/* dupACK-less receiver workaround */
+	if (tp->frto_counter > 1 || icsk->icsk_ca_state == TCP_CA_Loss)
+		return 0;
+
 	/* Avoid expensive walking of rexmit queue if possible */
 	if (tp->retrans_out > 1)
 		return 0;
-- 
1.5.2.2

---696208474-529547943-1216309981=:13775--
