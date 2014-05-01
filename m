From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [3.15-rc3] Bisected: xen-netback mangles packets between two guests on a bridge since merge of "TX grant mapping with SKBTX_DEV_ZEROCOPY instead of copy" series.
Date: Thu, 1 May 2014 17:40:53 +0200
Message-ID: <1046603646.20140501174053@eikelenboom.it>
References: <395225650.20140430124506@eikelenboom.it> <536250F9.7060405@citrix.com> <1967602892.20140501160513@eikelenboom.it> <53626563.8010404@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:41107 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752809AbaEAPk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 11:40:57 -0400
In-Reply-To: <53626563.8010404@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thursday, May 1, 2014, 5:16:51 PM, you wrote:

> On 01/05/14 15:05, Sander Eikelenboom wrote:
>>
>> Thursday, May 1, 2014, 3:49:45 PM, you wrote:
>>
>>> On 30/04/14 11:45, Sander Eikelenboom wrote:
>>>>       Another point would be: what *correctness* testing is actually done on the xen-net* patches ?
>>> I can speak only about my patches: I have manually tested them for the
>>> usecases where they likely to make a difference, plus they went through
>>> Xenserver's full test suite several times.
>>
>> I think Paul's patches for 3.14 also went through this testsuite fine, however
>> it did have a bug in it. Does this testsuite include a test which causes a
>> diverse pattern of frags (for both tx and rx case) ?
> Unfortunately these tests doesn't directly try with various skb layouts, 
> but it depends on the sending application/kernel what kind of packet 
> they feed in to netback/netfront.
> I was always thinking we should create a testing facility where we can 
> generate various different skb's and feed them in at an arbitrary part 
> of the networking stack. Or does such thing already exist?

Yesterday i tried to get packetdrill (https://code.google.com/p/packetdrill/) to 
work to see if i could reproduce with one of it's tests, but didn't get the 
client server stuff working. It seems it has helped with finding and fixing 
previous kernel networking bugs.
 
>>
>>
>>>>       As i suspect this is again about fragmented packets .. that doesn't seem to be included in any test case while it actually seems to be a case which is hard to get right...
>>> Beware, there are frags and frag_list which are two entirely different
>>> things with confusing names. In netback case, frags are used to pass
>>> through large packets for a long time. frag_list is used only since my
>>> grant mapping patches, to handle older guests (see comment in
>>> include/xen/interface/io/netif.h for XEN_NETIF_NR_SLOTS_MIN)
>>
>> Ah ok .. it's not about the frags in the packets being handled, but the frag
>> mechanism is supposed to be used internally ?
> Yes, the skb on the frag_list should contain no linear data but that 
> extra frag the guest sent to netback. After the grant operations are 
> done, xenvif_handle_frag_list coalesce the frags and that extra skb into 
> brand new, PAGE_SIZE frags.

>>
>> If so .. there is at least something wrong in the "older guest" detection,
>> because both dom0 and PV guests are running the same 3.15-rc3 kernel.
> That seems very odd ... Can you check ethtool -S vifX.Y in Dom0? 
> tx_frag_overflow will count the packets with too many frags

ethtool -S vif9.0
NIC statistics:
     rx_gso_checksum_fixup: 0
     tx_zerocopy_sent: 25621
     tx_zerocopy_success: 11047
     tx_zerocopy_fail: 14574
     tx_frag_overflow: 8

tx_frag_overflow was 0 until the http put of 100mb starts and gives the error.
