From: "Chris Engel" <chrisengel@gmail.com>
Subject: Re: [PATCH] spidernet: Fix problem sending IP fragments
Date: Thu, 1 Mar 2007 16:52:54 -0600
Message-ID: <1e548a3f0703011452u6dde9c53ifde2fa41fe5f4c38@mail.gmail.com>
References: <200702281521.34277.n.eicker@fz-juelich.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0024065830=="
Cc: linuxppc-dev@ozlabs.org, Adam Emerich <aemerich@us.ibm.com>,
	netdev@vger.kernel.org
To: "Norbert Eicker" <n.eicker@fz-juelich.de>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <200702281521.34277.n.eicker@fz-juelich.de>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Mime-version: 1.0
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

--===============0024065830==
Content-Type: multipart/alternative;
	boundary="----=_Part_43142_11167713.1172789574795"

------=_Part_43142_11167713.1172789574795
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I tried to apply this patch to 2.6.21-rc2 and CHECKSUM_HW appears to be
changed to CHECKSUM_COMPLETE at least in what I could find in skbuff.h .

Is CHECKSUM_COMPLETE the right value to use instead of CHECKSUM_HW ?

On 2/28/07, Norbert Eicker <n.eicker@fz-juelich.de> wrote:
>
> Hi,
>
> I found out that the spidernet-driver is unable to send fragmented IP
> frames.
>
> Let me just recall the basic structure of "normal" UDP/IP/Ethernet
> frames (that actually work):
> - It starts with the Ethernet header (dest MAC, src MAC, etc.)
> - The next part is occupied by the IP header (version info, length of
> packet, id=0, fragment offset=0, checksum, from / to address, etc.)
> - Then comes the UDP header (src / dest port, length, checksum)
> - Actual payload
> - Ethernet checksum
>
> Now what's different for IP fragment:
> - The IP header has id set to some value (same for all fragments),
> offset is set appropriately (i.e. 0 for first fragment, following
> according to size of other fragments), size is the length of the frame.
> - UDP header is unchanged. I.e. length is according to full UDP
> datagram, not just the part within the actual frame! But this is only
> true within the first frame: all following frames don't have a valid
> UDP-header at all.
>
> The spidernet silicon seems to be quite intelligent: It's able to
> compute (IP / UDP / Ethernet) checksums on the fly and tests if frames
> are conforming to RFC -- at least conforming to RFC on complete frames.
>
> But IP fragments are different as explained above:
> I.e. for IP fragments containing part of a UDP datagram it sees
> incompatible length in the headers for IP and UDP in the first frame
> and, thus, skips this frame. But the content *is* correct for IP
> fragments. For all following frames it finds (most probably) no valid
> UDP header at all. But this *is* also correct for IP fragments.
>
> The Linux IP-stack seems to be clever in this point. It expects the
> spidernet to calculate the checksum (since the module claims to be able
> to do so) and marks the skb's for "normal" frames accordingly
> (ip_summed set to CHECKSUM_HW).
> But for the IP fragments it does not expect the driver to be capable to
> handle the frames appropriately. Thus all checksums are allready
> computed. This is also flaged within the skb (ip_summed set to
> CHECKSUM_NONE).
>
> Unfortunately the spidernet driver ignores that hints. It tries to send
> the IP fragments of UDP datagrams as normal UDP/IP frames. Since they
> have different structure the silicon detects them the be not
> "well-formed" and skips them.
>
> The following one-liner against 2.6.21-rc2 changes this behavior. If the
> IP-stack claims to have done the checksumming, the driver should not
> try to checksum (and analyze) the frame but send it as is.
>
> Signed-off-by: Norbert Eicker <n.eicker@fz-juelich.de>
> ---
> diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
> index 3b91af8..31507ac 100644
> --- a/drivers/net/spider_net.c
> +++ b/drivers/net/spider_net.c
> @@ -719,7 +719,7 @@ spider_net_prepare_tx_descr(struct spide
>                         SPIDER_NET_DESCR_CARDOWNED |
> SPIDER_NET_DMAC_NOCS;
>         spin_unlock_irqrestore(&chain->lock, flags);
>
> -       if (skb->protocol == htons(ETH_P_IP))
> +       if (skb->protocol == htons(ETH_P_IP) && skb->ip_summed ==
> CHECKSUM_HW)
>                 switch (skb->nh.iph->protocol) {
>                 case IPPROTO_TCP:
>                         hwdescr->dmac_cmd_status |= SPIDER_NET_DMAC_TCP;
>
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@ozlabs.org
> https://ozlabs.org/mailman/listinfo/linuxppc-dev
>



-- 
   Chris

------=_Part_43142_11167713.1172789574795
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I tried to apply this patch to 2.6.21-rc2 and CHECKSUM_HW appears to be changed to CHECKSUM_COMPLETE at least in what I could find in skbuff.h .&nbsp; <br><br>Is CHECKSUM_COMPLETE the right value to use instead of CHECKSUM_HW ?
<br><br><div><span class="gmail_quote">On 2/28/07, <b class="gmail_sendername">Norbert Eicker</b> &lt;<a href="mailto:n.eicker@fz-juelich.de">n.eicker@fz-juelich.de</a>&gt; wrote:</span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
Hi,<br><br>I found out that the spidernet-driver is unable to send fragmented IP<br>frames.<br><br>Let me just recall the basic structure of &quot;normal&quot; UDP/IP/Ethernet<br>frames (that actually work):<br> - It starts with the Ethernet header (dest MAC, src MAC, etc.)
<br> - The next part is occupied by the IP header (version info, length of<br>packet, id=0, fragment offset=0, checksum, from / to address, etc.)<br> - Then comes the UDP header (src / dest port, length, checksum)<br> - Actual payload
<br> - Ethernet checksum<br><br>Now what&#39;s different for IP fragment:<br> - The IP header has id set to some value (same for all fragments),<br>offset is set appropriately (i.e. 0 for first fragment, following<br>according to size of other fragments), size is the length of the frame.
<br> - UDP header is unchanged. I.e. length is according to full UDP<br>datagram, not just the part within the actual frame! But this is only<br>true within the first frame: all following frames don&#39;t have a valid<br>
UDP-header at all.<br><br>The spidernet silicon seems to be quite intelligent: It&#39;s able to<br>compute (IP / UDP / Ethernet) checksums on the fly and tests if frames<br>are conforming to RFC -- at least conforming to RFC on complete frames.
<br><br>But IP fragments are different as explained above:<br>I.e. for IP fragments containing part of a UDP datagram it sees<br>incompatible length in the headers for IP and UDP in the first frame<br>and, thus, skips this frame. But the content *is* correct for IP
<br>fragments. For all following frames it finds (most probably) no valid<br>UDP header at all. But this *is* also correct for IP fragments.<br><br>The Linux IP-stack seems to be clever in this point. It expects the<br>spidernet to calculate the checksum (since the module claims to be able
<br>to do so) and marks the skb&#39;s for &quot;normal&quot; frames accordingly<br>(ip_summed set to CHECKSUM_HW).<br>But for the IP fragments it does not expect the driver to be capable to<br>handle the frames appropriately. Thus all checksums are allready
<br>computed. This is also flaged within the skb (ip_summed set to<br>CHECKSUM_NONE).<br><br>Unfortunately the spidernet driver ignores that hints. It tries to send<br>the IP fragments of UDP datagrams as normal UDP/IP frames. Since they
<br>have different structure the silicon detects them the be not<br>&quot;well-formed&quot; and skips them.<br><br>The following one-liner against 2.6.21-rc2 changes this behavior. If the<br>IP-stack claims to have done the checksumming, the driver should not
<br>try to checksum (and analyze) the frame but send it as is.<br><br>Signed-off-by: Norbert Eicker &lt;<a href="mailto:n.eicker@fz-juelich.de">n.eicker@fz-juelich.de</a>&gt;<br>---<br>diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
<br>index 3b91af8..31507ac 100644<br>--- a/drivers/net/spider_net.c<br>+++ b/drivers/net/spider_net.c<br>@@ -719,7 +719,7 @@ spider_net_prepare_tx_descr(struct spide<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SPIDER_NET_DESCR_CARDOWNED |
<br>SPIDER_NET_DMAC_NOCS;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;spin_unlock_irqrestore(&amp;chain-&gt;lock, flags);<br><br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (skb-&gt;protocol == htons(ETH_P_IP))<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (skb-&gt;protocol == htons(ETH_P_IP) &amp;&amp; skb-&gt;ip_summed ==
<br>CHECKSUM_HW)<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;switch (skb-&gt;nh.iph-&gt;protocol) {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;case IPPROTO_TCP:<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;hwdescr-&gt;dmac_cmd_status |= SPIDER_NET_DMAC_TCP;<br><br>_______________________________________________
<br>Linuxppc-dev mailing list<br><a href="mailto:Linuxppc-dev@ozlabs.org">Linuxppc-dev@ozlabs.org</a><br><a href="https://ozlabs.org/mailman/listinfo/linuxppc-dev">https://ozlabs.org/mailman/listinfo/linuxppc-dev</a><br></blockquote>
</div><br><br clear="all"><br>-- <br>&nbsp;&nbsp; Chris

------=_Part_43142_11167713.1172789574795--

--===============0024065830==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-dev
--===============0024065830==--
