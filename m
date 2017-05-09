From: Andy Duan <fugang.duan@nxp.com>
Subject: RE: FEC on i.MX 7 transmit queue timeout
Date: Tue, 9 May 2017 10:35:18 +0000
Message-ID: <AM4PR0401MB2260F316B39A05C659EE1ECDFFEF0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
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
 <d48a6d17b05280331642ea683caabc81@agner.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "festevam@gmail.com" <festevam@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "netdev-owner@vger.kernel.org" <netdev-owner@vger.kernel.org>
To: Stefan Agner <stefan@agner.ch>, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr30040.outbound.protection.outlook.com ([40.107.3.40]:44348
        "EHLO EUR03-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751368AbdEIKfV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 9 May 2017 06:35:21 -0400
In-Reply-To: <d48a6d17b05280331642ea683caabc81@agner.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Agner <stefan@agner.ch> Sent: Tuesday, May 09, 2017 2:23 AM
>To: Andy Duan <fugang.duan@nxp.com>; Andrew Lunn <andrew@lunn.ch>
>Cc: festevam@gmail.com; netdev@vger.kernel.org; netdev-
>owner@vger.kernel.org
>Subject: Re: FEC on i.MX 7 transmit queue timeout
>
>On 2017-05-07 19:13, Andy Duan wrote:
>> From: Andrew Lunn <andrew@lunn.ch> Sent: Friday, May 05, 2017 8:24 PM
>>>To: Andy Duan <fugang.duan@nxp.com>
>>>Cc: Stefan Agner <stefan@agner.ch>; festevam@gmail.com;
>>>netdev@vger.kernel.org; netdev-owner@vger.kernel.org
>>>Subject: Re: FEC on i.MX 7 transmit queue timeout
>>>
>>>> No, it is not workaround. As i said, quque1 and queue2 are for AVB
>>>> paths have higher priority in transmition.
>>>
>>>Does this higher priority result in the low priority queue being
>>>starved? Is that why the timer goes off? What happens when somebody
>>>does use AVB. Are we back to the same problem? This is what seems to
>>>make is sounds like a work around, not a fix.
>>>
>>>     Andrew
>> Yes, queue0 may be blocked by queue1 and queue2, then the queue0
>> watchdog time maybe triggered.
>> If somebody use AVB quque1 and queue2, the remaining bandwidth is for
>> queue0, for example, in 100Mbps system, quque1 cost 50Mbps bandwidth
>> and queue2 cost 50Mbps bandwidth for audio and video streaming, then
>> queue0 (best effort) has 0 bandwidth that limit user case cannot have
>> asynchronous frames (IP(tcp/udp)) on networking. Of course these is
>> extreme case.
>> In essentially,  asynchronous frames (IP) go queue0 for the original
>> design. To do these just implement .ndo_select_queue() callback in
>> driver like fsl tree.
>
>I guess you refer to this commit?
>
>http://git.freescale.com/git/cgit.cgi/imx/linux-
>imx.git/commit/?h=3Dimx_4.1.15_2.0.0_ga&id=3Db0d8fa989651baf847287f6888f4d
>7b723e2a207
>
>It seems that by default there is a Credit-based scheme enabled
>(ENETx_QOS[TX_SCHEME] =3D 000). The driver enables the queue1/2 and
>assigns it each 50% of the bandwidth (IDLE_SLOPE_1/2 is set to 0x200, whic=
h
>according to the register description of IDLE_SLOPE means BW fraction of 0=
.5!).
>This actually violates even the note in register
>ENETx_DMAnCFG:
>
>"NOTE: For AVB applications, the BW fraction of class 1 and class 2 combin=
ed
>must not exceed .75."
>
Yes, the suggested BW fraction for class1 and class2 must not exceed .75, o=
therwise best effort
Queue will be blocked then watchdog timeout on queue0.

How to set the BW fraction that is up to user case.

>Instead of using the credit based scheme we could switch to round robin, b=
ut
>not sure if that is what we want.
>=20
Using round robin has no meaning for AVB feature.

>What is the default criteria to select queues when .ndo_select_queue is no=
t
>provided? I guess it tries to balance individual streams/processes for bet=
ter
>SMP performance?
>
Since AVB audio/video streaming is based on IEEE1722 format,  .ndo_select_q=
ueue just parse
the avb streaming and insect the skb into class1 and class2 queues, which a=
re individual streaming and processes.
