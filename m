From: Stefan Agner <stefan@agner.ch>
Subject: Re: FEC on i.MX 7 transmit queue timeout
Date: Mon, 08 May 2017 11:22:35 -0700
Message-ID: <d48a6d17b05280331642ea683caabc81@agner.ch>
References: <86b63ee28acfff3426c4a0bf72d848c1@agner.ch>
 <2bdd64ab-5644-e0a0-9bfe-b8dd2fca7abb@nxp.com>
 <80191e7c9df5871cd450f13b9ea47a10@agner.ch>
 <ab1fc814-4a81-9eb0-b20b-2cd325158ba8@nxp.com>
 <e366479239b66ba80415b5594def2369@agner.ch>
 <AM4PR0401MB2260F011313883C522EA7684FFEA0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <e044b850a90e7112028cc12977d15cf2@agner.ch>
 <e739d361-c20f-0de1-cdd1-c9aa13a0d11a@nxp.com>
 <110a7a48649cfcbbee46340c230e9008@agner.ch>
 <46a27329-36df-1eaf-1321-24db037842fe@nxp.com>
 <20170505122330.GA23432@lunn.ch>
 <AM4PR0401MB2260D9D293EE8A37B93554F6FFEE0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: festevam@gmail.com, netdev@vger.kernel.org,
        netdev-owner@vger.kernel.org
To: Andy Duan <fugang.duan@nxp.com>, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kmu-office.ch ([178.209.48.109]:34981 "EHLO
        mail.kmu-office.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752315AbdEHSXH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 14:23:07 -0400
In-Reply-To: <AM4PR0401MB2260D9D293EE8A37B93554F6FFEE0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-05-07 19:13, Andy Duan wrote:
> From: Andrew Lunn <andrew@lunn.ch> Sent: Friday, May 05, 2017 8:24 PM
>>To: Andy Duan <fugang.duan@nxp.com>
>>Cc: Stefan Agner <stefan@agner.ch>; festevam@gmail.com;
>>netdev@vger.kernel.org; netdev-owner@vger.kernel.org
>>Subject: Re: FEC on i.MX 7 transmit queue timeout
>>
>>> No, it is not workaround. As i said, quque1 and queue2 are for AVB
>>> paths have higher priority in transmition.
>>
>>Does this higher priority result in the low priority queue being starved? Is that
>>why the timer goes off? What happens when somebody does use AVB. Are
>>we back to the same problem? This is what seems to make is sounds like a
>>work around, not a fix.
>>
>>     Andrew
> Yes, queue0 may be blocked by queue1 and queue2, then the queue0
> watchdog time maybe triggered.
> If somebody use AVB quque1 and queue2, the remaining bandwidth is for
> queue0, for example, in 100Mbps system, quque1 cost 50Mbps bandwidth
> and queue2 cost 50Mbps bandwidth for audio and video streaming, then
> queue0 (best effort) has 0 bandwidth that limit user case cannot have 
> asynchronous frames (IP(tcp/udp)) on networking. Of course these is
> extreme case.
> In essentially,  asynchronous frames (IP) go queue0 for the original
> design. To do these just implement .ndo_select_queue() callback in
> driver like fsl tree.

I guess you refer to this commit?

http://git.freescale.com/git/cgit.cgi/imx/linux-imx.git/commit/?h=imx_4.1.15_2.0.0_ga&id=b0d8fa989651baf847287f6888f4d7b723e2a207

It seems that by default there is a Credit-based scheme enabled
(ENETx_QOS[TX_SCHEME] = 000). The driver enables the queue1/2 and
assigns it each 50% of the bandwidth (IDLE_SLOPE_1/2 is set to 0x200,
which according to the register description of IDLE_SLOPE means BW
fraction of 0.5!). This actually violates even the note in register
ENETx_DMAnCFG:

"NOTE: For AVB applications, the BW fraction of class 1 and class 2
combined must not exceed .75."

Instead of using the credit based scheme we could switch to round robin,
but not sure if that is what we want.

What is the default criteria to select queues when .ndo_select_queue is
not provided? I guess it tries to balance individual streams/processes
for better SMP performance?
