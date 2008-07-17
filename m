From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Thu, 17 Jul 2008 16:55:25 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0807171537560.13775@wrl-59.cs.helsinki.fi>
References: <47EA0DAB.7080205@securenet.de> <200807151810.45942.thomas.jarosch@intra2net.com>
 <Pine.LNX.4.64.0807152312080.6254@wrl-59.cs.helsinki.fi>
 <200807161103.07821.thomas.jarosch@intra2net.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-678092178-1216302925=:13775"
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	"=?ISO-8859-1?Q?D=E2niel_Fraga?=" <fragabr@gmail.com>,
	David Miller <davem@davemloft.net>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <200807161103.07821.thomas.jarosch@intra2net.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-678092178-1216302925=:13775
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 16 Jul 2008, Thomas Jarosch wrote:

> On Tuesday, 15. July 2008 22:17:47 Ilpo Järvinen wrote:
> > FRTO in 2.6.24.y is broken, I recently fixed couple of things in FRTO,
> > late 2.6.25.y or 2.6.26 should be used to have all the fixes. If you can
> > reproce with either one, please tcpdump it
> 
> As the dumps are really big, I uploaded them to a temporary space.
> Included are two tcpdumps of stalling connections using git "master".
> The first one stalls around ~1.3mb, the second one around ~4mb.
> 
> Get it from here:
> http://www.intra2net.com/de/download/tcpdump/tcp_frto_tcpdumps.tar.bz2

Thanks for the dumps, it's pretty clear picture now... Also, I read this 
thread fully today, your note in the initial mail is correct and relevant:
"The picture is similar to Sven's issue reported backed in march: Some ACK 
packets are missing (as if the remote side never sent them)."

> There is another box in front of my test system doing NAT
> which is running 2.6.24.7. I've tested with and without tcp_frto
> on that box to make sure it's not FRTO related.

Did you accidently add "not" here? :-)

> I've also included a tcpdump with FRTO disabled, so you can see
> the connection is actually working. Just by looking at the packet flow
> while tracing the connection looks much smoother without FRTO
> and doesn't stall for seconds here and there.

Yes, but why it happens, let me explain...

 "A TCP receiver SHOULD send an immediate duplicate ACK when an out-
  of-order segment arrives." [RFC2581]

FRTO is partially built on assumption that the receiver does the right 
thing (tm), ie., sends duplicate ACKs. But in this case the server for 
some reason has chosen to ignore this SHOULD here in the standards, 
which stands for this:

"3. SHOULD   This word, or the adjective "RECOMMENDED", mean that there
   may exist valid reasons in particular circumstances to ignore a
   particular item, but the full implications must be understood and
   carefully weighed before choosing a different course." [RFC2119]

It could be that the duplicate ACKs are missing due to bug,
misconfiguration or broken middlebox at the provider. This is somewhat 
similar to the case we worked-around recently with the network printers 
that do accept data only in-order and just dupack rest. ...I actually 
predicted this dupACK-less receiver problem back then (not sure if I 
mentioned it in a mail though) but it seemed like small box problem 
rather than some big box like mail server problem. It seems hardly a 
reasonable way to interpret "in particular circumstances" as never send 
dupACKs (which have other benefits too).

Because those duplicate ACKs never arrive for the new data segments FRTO 
is segment, FRTO never falls back to conventional recovery but RTO expires 
again for a different segment and FRTO algorithm is retried with the same 
results. So TCP is basically in RTO loop making slowly progress. If there 
isn't external timeout, the situation is eventually recovered when all 
data ACKed by a big cumulative ACK or earlier when a temporary dupACK 
lossage end (like it should be at worst).

It would quite interesting to know more details about the mail server and 
why the duplicate ACKs are not generated or don't ever reach the sender 
but I guess the details are out of reach?

One option would be to disable reentry to FRTO when some progress was 
made... Please try with the patch below... It has some non-desirable 
properties in microbenchmarks but adds robustness, it's not clear to me 
how often the reentry would benefit in real life scenarios but I'd assume 
that most RTOs that occur for a later segment are not spurious anyway 
even when the first was.


-- 
 i.

--

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
cumulative ACK covers all outstanding data.

This impacts FRTO accuracy as we lose ability to detect more than
one spurious segment per window with NewReno. Performance impact
might not be visible unless one sets up an microbenchmark... :-)

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d6ea970..3f7cce9 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1714,6 +1714,10 @@ int tcp_use_frto(struct sock *sk)
 	if (tcp_is_sackfrto(tp))
 		return 1;
 
+	/* dupACK-less receiver workaround */
+	if (tp->frto_counter > 1)
+		return 0;
+
 	/* Avoid expensive walking of rexmit queue if possible */
 	if (tp->retrans_out > 1)
 		return 0;
-- 
1.5.2.2

---696208474-678092178-1216302925=:13775--
