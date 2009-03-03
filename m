From: Gary Thomas <gary@mlbassoc.com>
Subject: Re: Marvell 88E609x switch?
Date: Tue, 03 Mar 2009 06:25:53 -0700
Message-ID: <49AD2FE1.60305@mlbassoc.com>
References: <20090227145746.GD17040@xi.wantstofly.org>	 <49A801E6.1040502@mlbassoc.com> <20090227151441.GE17040@xi.wantstofly.org>	 <49A80606.1040508@mlbassoc.com> <20090227152721.GG17040@xi.wantstofly.org>	 <49A806C5.1010200@mlbassoc.com> <20090227153102.GH17040@xi.wantstofly.org>	 <49A80A75.8000101@mlbassoc.com> <20090227155224.GK17040@xi.wantstofly.org>	 <Pine.LNX.4.64.0902272211260.19905@ask.diku.dk>	 <20090227222802.GZ17040@xi.wantstofly.org>	 <1235991382.30736.62.camel@localhost.localdomain>	 <1235991937.30736.65.camel@localhost.localdomain>	 <49ABF7DF.8060302@mlbassoc.com> <49ABF9A9.2040608@mlbassoc.com>	 <Pine.LNX.4.64.0903022237580.1863@ask.diku.dk>	 <49AC5E6F.3010204@mlbassoc.com>	 <1236070372.30736.87.camel@localhost.localdomain>	 <49AD1C81.1020106@mlbassoc.com> <1236083560.3073
 6.114.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	netdev <netdev@vger.kernel.org>
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 137-67-76-76.skybeam.com ([76.76.67.137]:1230 "EHLO
	mail.chez-thomas.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752682AbZCCN0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 08:26:21 -0500
In-Reply-To: <1236083560.30736.114.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer wrote:
> On Tue, 2009-03-03 at 05:03 -0700, Gary Thomas wrote:
>> Jesper Dangaard Brouer wrote:
>>> On Mon, 2009-03-02 at 15:32 -0700, Gary Thomas wrote:
>>>> Any ideas how I might troubleshoot why packets that come
>>>> into lan1.1 (port 0) aren't being pushed to the CPU port?
>>> The switch supports port monitoring, with seperate ingress and egress
>>> mapping, thus you could place another PC on another port and direct
>>> traffic towards that, and by tcpdump inspecting ingress and egress on
>>> the different physical ports... Thats how I debugged it once...
>> I'm a bit fuzzy on this - could you explain in a bit more detail?
> 
> You basically set the monitor destination port via REG_GLOBAL reg 0x1A
> "Monitor Control".
> 
> /* Register: Monitor Control (0x1A)
>    -------------------------
>     bit 15:12= Ingress Monitor Dest
>     bit 11:8 = Egress  Monitor Dest
>     bit  7:4 = ARP Dest
>     bit  3:0 = Reserved
> */
> 
> Then you configure the port register 0x08 "port control2", that this
> port is to be monitored: bit5=monitor_egress and bit4=monitor_ingress.
> 
> /* Register: Port Control 2 (0x8)
>    ------------------------
>     bit 15    = IgnoreFSC: Force good FSC in frame
>     bit 14    = VTU_prio_override   : VTU    setting overrides prio
>     bit 13    = ATU_SA_prio_overrite: ATU SA setting overrides prio
>     bit 12    = ATU_DA_prio_overrite: ATU DA setting overrides prio
>     bit 11:10 = 802.1Q mode
>      [00] = <Disabled>: use VLANtable only
>      [01] = <Fallback>: fallback to VLANTable
>      [10] = <Check>   : drop on miss (eq. not in VTU)
>      [11] = <Secure>  : drop on miss and membership violation
>     bit 9     = Discard Tagged
>     bit 8     = Discard Untagged
>     bit 7     = MapDA: Map using DA hits
>     bit 6     = Default Forward (normal switch operation)
>     bit 5     = Monitor egress
>     bit 4     = Monitor ingress
>     bit 3:0   = CPU port
> */
> 
> 
> Reading through the "Monitor Control" register description, there is a
> interesting description about the "ARPdest" setting... Could you try to
> set it to the CPU port and see if that helps?
> 

It's already set this way (sans bits 4&5)
	REG_WRITE(REG_GLOBAL, 0x1a, (ds->cpu_port * 0x1100) | 0x00f0);

I tried turning on bit 4 on port 0 (lan1.1).  Now I can see what's
coming into that port, but it doesn't look right:

Here's the ARP going out:

13:46:29.348449 00:1d:11:81:00:00 > ff:ff:ff:ff:ff:ff, ethertype Unknown (0x4000), length 46:
        0x0000:  ffff ffff ffff 001d 1181 0000 4000 0000
        0x0010:  0806 0001 0800 0604 0001 001d 1181 0000
        0x0020:  c0a8 0cbc 0000 0000 0000 c0a8 0c12

Here's the ARP reply coming back:

13:46:29.348907 00:1e:c9:2f:73:6c > 00:1d:11:81:00:00, ethertype Unknown (0x8004), length 64:
        0x0000:  001d 1181 0000 001e c92f 736c 8004 0000
        0x0010:  0806 0001 0800 0604 0002 001e c92f 736c
        0x0020:  c0a8 0c12 001d 1181 0000 c0a8 0cbc 0000
        0x0030:  0000 0000 0000 0000 0000 0000 0000 0000

I understand the 0x4000 DSA tag going out, but what's the 0x8004?

-- 
------------------------------------------------------------
Gary Thomas                 |  Consulting for the
MLB Associates              |    Embedded world
------------------------------------------------------------
