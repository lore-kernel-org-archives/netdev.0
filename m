From: =?gb2312?B?1cXKpL7Z?= <zhangshengju@cmss.chinamobile.com>
Subject: RE: [net,v2] neigh: fix the loop index error in neigh dump
Date: Mon, 28 Nov 2016 14:28:18 +0800
Message-ID: <002b01d24940$9e16e1c0$da44a540$@cmss.chinamobile.com>
References: <1480296725-5563-1-git-send-email-zhangshengju@cmss.chinamobile.com> <caa11887-00b9-d2f1-7c0b-5b5096b42f56@cumulusnetworks.com> <001c01d2491f$fcd53250$f67f96f0$@cmss.chinamobile.com> <6d1a324e-e29e-e2dd-a6fc-1e9b4455cb3d@cumulusnetworks.com> <001d01d24922$9a16b1e0$ce4415a0$@cmss.chinamobile.com> <a01fcd54-c0ed-9d05-743a-27592d845c56@cumulusnetworks.com> <6859d40b-0049-513a-6dc4-162d383ef7b9@cumulusnetworks.com> <001e01d24932$f7c0dd10$e7429730$@cmss.chinamobile.com> <7e3623c4-a55e-5809-ca9a-2dbd59cda871@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="gb2312"
Content-Transfer-Encoding: 8BIT
To: "'David Ahern'" <dsa@cumulusnetworks.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:19744 "EHLO
        cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750879AbcK1G2r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 01:28:47 -0500
In-Reply-To: <7e3623c4-a55e-5809-ca9a-2dbd59cda871@cumulusnetworks.com>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Ahern [mailto:dsa@cumulusnetworks.com]
> Sent: Monday, November 28, 2016 1:07 PM
> To: 张胜举 <zhangshengju@cmss.chinamobile.com>;
> netdev@vger.kernel.org
> Subject: Re: [net,v2] neigh: fix the loop index error in neigh dump
> 
> On 11/27/16 9:50 PM, 张胜举 wrote:
> > No, when dump request must be processed by multiple 'recv/recvmsg'
> > system calls, idx stores which dev/neigh the previous call have
> > processed, so that next call will scan from the right place.
> 
> I have tested multiple calls and I do not see redundant information or
missing
> information.
> 
> >
> > So no matter whether the dev/neigh is filtered, the idx should be
> > increased anyway.
> 
> No, it does not. Again, idx is the index in the list of devices/ of
interest. It is
> NOT a device index nor is it the absolute index in the list. It is a
relative index.
> The filter is the same across recvmsg calls so the idx count is absolutely
fine.
> 
> Produce a test case that fails.
David, I know your point. And I agree with you that this will not make 
redundant or missing link information.

But this will cause the filtered out device be scanned multiple times. 

For example, assume that netlink message can only store two devices info.

And eth2-eth5 are filtered out.

For the first loop, idx will point to eth2, but the code already scan to
eth6.
eth0->eth1->eth2(out)->eth3(out)-> eth4(out)->eth5(out)->eth6->eth7
                         ^
The next loop, the code will start to scan from eth2 to eth8, but eth2-eth5 
already scanned by previous loop. After this loop, idx will point to eth4.
eth0->eth1->eth2(out)->eth3(out)->eth4(out)->eth5(out)->eth6->eth7->eth8
                                                                  ^
So this will cause the same device to be scanned multiple times.

Almost all other dump functions treat idx as the absolute index in the list,

and will not have the above problem. 

We don't treat this a bugfix, but i think we'd better in line with other 
dump functions.
