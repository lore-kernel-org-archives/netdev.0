From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] e100: Fix inconsistency in bad frames
	handling
Date: Mon, 06 Jun 2011 10:56:55 -0700
Message-ID: <4DED14E7.2050405@candelatech.com>
References: <BANLkTimpYniHhN6ccMXN7Lx3xDdK6sC+FQ@mail.gmail.com>
	<alpine.WNT.2.00.1106060940010.3568@JBRANDEB-DESK2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrea Merello <andrea.merello@gmail.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.WNT.2.00.1106060940010.3568@JBRANDEB-DESK2.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 06/06/2011 10:49 AM, Brandeburg, Jesse wrote:
>
> <added netdev>, removed other useless lists.
>
> On Sat, 4 Jun 2011, Andrea Merello wrote:
>> In e100 driver it seems that the intention was to accept bad frames in
>> promiscuous mode and loopback mode.
>> I think this is evident because of the following code in the driver:
>>
>> if (nic->flags&  promiscuous || nic->loopback) {
>> 		config->rx_save_bad_frames = 0x1;	/* 1=save, 0=discard */
>> 		config->rx_discard_short_frames = 0x0;	/* 1=discard, 0=save */
>> 		config->promiscuous_mode = 0x1;		/* 1=on, 0=off */
>> 	}
>>
>
> Hi, thanks for your work on e100.
>
>> However this intention is not really realized because bad frames are
>> discarded later by SW check.
>> This patch finally honors the above intention, making the RX code to
>> let bad frames to pass when the NIC is in promiscuous or loopback
>> mode.
>
> I think this may be a mistake by the authors of the software developers
> manual.  The manual suggests that save bad frames and save short frames
> should be enabled in promisc mode, but all of our other drivers *do not*
> save bad frames when in promiscuous mode (by design).  This is intentional
> because a bad frame is just that, bad, and with no hope of knowing if the
> data in it is okay/malicious/other.  I understand your reasoning above,
> but realistically the rx_save_bad_frames should NOT be set.  I'd ack a
> patch to comment that line out.
>
>> This helped me a lot to debug an FPGA ethernet core.
>> Maybe it can be also useful to someone else..
>
> I think this patch is just that, debug only. As a developer I understand
> why this is useful, but there is no reason any normal user would be able
> to benefit from this, so for now, sorry:
>
> NACK.

I think anyone sniffing a funky network would have benefit in
receiving all frames.  So, while it shouldn't be enabled by default,
it would be nice to have an ethtool command to turn on receiving
bad-crc frames, as well as receiving the 4-byte CRC on the end of
the packets.

It just so happens I have such a patch, in case others agree :)

Thanks,
Ben


>
>>
>> Thanks
>> Andrea
>>
>>   --- drivers/net/e100_orig.c     2011-06-14 23:29:38.322267075 +0200
>> +++ drivers/net/e100.c  2011-06-14 23:34:10.700791472 +0200
>> @@ -1975,7 +1975,8 @@ static int e100_rx_indicate(struct nic *
>>          skb_put(skb, actual_size);
>>          skb->protocol = eth_type_trans(skb, nic->netdev);
>>
>> -       if (unlikely(!(rfd_status&  cb_ok))) {
>> +       if (unlikely(!(nic->flags&  promiscuous || nic->loopback)&&
>> +           !(rfd_status&  cb_ok))) {
>>                  /* Don't indicate if hardware indicates errors */
>>                  dev_kfree_skb_any(skb);
>>          } else if (actual_size>  ETH_DATA_LEN + VLAN_ETH_HLEN) {
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


------------------------------------------------------------------------------
Simplify data backup and recovery for your virtual environment with vRanger.
Installation's a snap, and flexible recovery options mean your data is safe,
secure and there when you need it. Discover what all the cheering's about.
Get your free trial download today. 
http://p.sf.net/sfu/quest-dev2dev2 
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
