From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Source Specific Query of MLDv2 [PATCH]
Date: Fri, 6 Feb 2004 20:39:47 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF9F84892D.B2226F9C-ON88256E33.00185F62-88256E33.00196063@us.ibm.com>
References: <20040207.132233.21960944.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=07BBE4A0DF8BD9F28f9e8a93df938690918c07BBE4A0DF8BD9F2"
Cc: davem@redhat.com, hibi665@oki.com, netdev@oss.sgi.com,
        "Hideaki YOSHIFUJI" <yoshfuji@cerberus.hongo.wide.ad.jp>,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040207.132233.21960944.yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4A0DF8BD9F28f9e8a93df938690918c07BBE4A0DF8BD9F2
Content-type: text/plain; charset=US-ASCII







"Hideaki YOSHIFUJI" <yoshfuji@cerberus.hongo.wide.ad.jp> wrote on
02/06/2004 08:22:33 PM:

> Why not in icmpv6_rcv()?

      I don't understand this question. It's needed every place
*except* icmpv6_rcv().

> we need to do pskb_pull() before touching type/code.

      Yes, you're right; I'll add that.

> >
> > -     hdr = skb->nh.ipv6h;
> > -     if (ipv6_chk_mcast_addr(skb->dev, &hdr->daddr, &hdr->saddr))
> > -           deliver = 1;
> > -

> Please do not remove this.
> We need to check destination (but not source)
> because the driver may be in "promisc." mode.

      I'm not removing it, I'm moving it. The original code
is:

      ip6_mc_input()
            <filter check> (not much else, since no mc router code)
      ip6_input
            <parse extension headers>
            <deliver to ULP>

new is:
      ip6_mc_input()
            <inc stats, "#if 0" for mc router code>
      ip6_input
            <parse extension headers>
            <filter check>
            <deliver to ULP>

In promiscuous mode, it will parse the extension headers
for non-local multicasts before dropping them. But what
you suggested will do two multicast address look-ups for
every multicast packet (including the valid ones). One
for the destination and another for the destination/source
filter.
      The point where it's filtered is just after the
checksum is validated, and no ICMP errors can be reported
for multicast destinations, so the trade-off is 1) a
performance hit for every multicast packet or 2) parsing
potential extension headers (expected case won't have any
and it doesn't cost anything) for multicast packets that
we may drop.
      This patch implements option #2.

                        +-DLS
--0__=07BBE4A0DF8BD9F28f9e8a93df938690918c07BBE4A0DF8BD9F2
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p><tt>&quot;Hideaki YOSHIFUJI&quot; &lt;yoshfuji@cerberus.hongo.wide.ad.jp&gt; wrote on 02/06/2004 08:22:33 PM:<br>
</tt><br>
<tt>&gt; Why not in icmpv6_rcv()?</tt><br>
<br>
<tt>	I don't understand this question. It's needed every place</tt><br>
<tt>*except* icmpv6_rcv().</tt><br>
<tt><br>
&gt; we need to do pskb_pull() before touching type/code.</tt><br>
<br>
<tt>	Yes, you're right; I'll add that.<br>
<br>
&gt; &gt;<br>
&gt; &gt; - &nbsp; &nbsp; hdr = skb-&gt;nh.ipv6h;<br>
&gt; &gt; - &nbsp; &nbsp; if (ipv6_chk_mcast_addr(skb-&gt;dev, &amp;hdr-&gt;daddr, &amp;hdr-&gt;saddr))<br>
&gt; &gt; - &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; deliver = 1;<br>
&gt; &gt; -<br>
</tt><br>
<tt>&gt; Please do not remove this.<br>
&gt; We need to check destination (but not source)<br>
&gt; because the driver may be in &quot;promisc.&quot; mode.</tt><br>
<br>
<tt>	I'm not removing it, I'm moving it. The original code</tt><br>
<tt>is:</tt><br>
<br>
<tt>	ip6_mc_input()</tt><br>
<tt>		&lt;filter check&gt; (not much else, since no mc router code)</tt><br>
<tt>	ip6_input</tt><br>
<tt>		&lt;parse extension headers&gt;</tt><br>
<tt>		&lt;deliver to ULP&gt;</tt><br>
<br>
<tt>new is:</tt><br>
<tt>	ip6_mc_input()</tt><br>
<tt>		&lt;inc stats, &quot;#if 0&quot; for mc router code&gt;</tt><br>
<tt>	ip6_input</tt><br>
<tt>		&lt;parse extension headers&gt;</tt><br>
<tt>		&lt;filter check&gt;</tt><br>
<tt>		&lt;deliver to ULP&gt;</tt><br>
<br>
<tt>In promiscuous mode, it will parse the extension headers</tt><br>
<tt>for non-local multicasts before dropping them. But what</tt><br>
<tt>you suggested will do two multicast address look-ups for</tt><br>
<tt>every multicast packet (including the valid ones). One</tt><br>
<tt>for the destination and another for the destination/source</tt><br>
<tt>filter.</tt><br>
<tt>	The point where it's filtered is just after the</tt><br>
<tt>checksum is validated, and no ICMP errors can be reported</tt><br>
<tt>for multicast destinations, so the trade-off is 1) a</tt><br>
<tt>performance hit for every multicast packet or 2) parsing</tt><br>
<tt>potential extension headers (expected case won't have any</tt><br>
<tt>and it doesn't cost anything) for multicast packets that</tt><br>
<tt>we may drop.</tt><br>
<tt>	This patch implements option #2.</tt><br>
<br>
<tt>				+-DLS</tt><br>
</body></html>
--0__=07BBE4A0DF8BD9F28f9e8a93df938690918c07BBE4A0DF8BD9F2--
