From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next 02/16] i40e/i40evf: Rewrite logic for 8 descriptor per
 packet check
Date: Tue, 29 Mar 2016 22:19:18 -0700
Message-ID: <CAKgT0Udt1b8RYdh4Ex+34i+V4dRZWUuYWM=MpJK_DhuqGecjZQ@mail.gmail.com>
References: <1455875651-21696-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1455875651-21696-3-git-send-email-jeffrey.t.kirsher@intel.com>
	<CAEuXFEwPdnh8LNMXRP6fnasXO3P-iW-k1qPciXqayY+7c6=b0w@mail.gmail.com>
	<CAEuXFEwdc1VZ6bcnMy1sqFvm=tr3zDwauW6oW8WO77F9oeERcA@mail.gmail.com>
	<CAKgT0Uf8_Eb0G+k6N4vz69HefM3_oCkj7PB30z3keBCR4HAUnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Dave Miller <davem@davemloft.net>,
	Alexander Duyck <aduyck@mirantis.com>,
	NetDEV list <netdev@vger.kernel.org>,
	Neil Horman <nhorman@redhat.com>, sassmann@redhat.com,
	John Greene <jogreene@redhat.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:34414 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752685AbcC3FTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 01:19:19 -0400
Received: by mail-io0-f179.google.com with SMTP id e3so52506970ioa.1
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 22:19:19 -0700 (PDT)
In-Reply-To: <CAKgT0Uf8_Eb0G+k6N4vz69HefM3_oCkj7PB30z3keBCR4HAUnQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 29, 2016 at 7:20 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Tue, Mar 29, 2016 at 5:34 PM, Jesse Brandeburg
> <jesse.brandeburg@gmail.com> wrote:
>> stupid gmail... sent again to the list, sorry for duplicate (but
>> formatted better this time)
>>
>>
>> Hey Alex, this patch appears to have caused a regression (probably both
>> i40e/i40evf).  Easily reproducible running rds-stress (see the thread titled
>> "i40e card Tx resets", the middle post by sowmini has the repro steps,
>> ignore the pktgen discussion in the thread.)
>
> I'll see about setting up rds tomorrow.  It should be pretty straight forward.
>
>> I've spent some time trying to figure out the right fix, but keep getting
>> stuck in the complicated logic of the function, so I'm sending this in the
>> hope you'll take a look.
>>
>> This is (one example of) the skb that doesn't get linearized:
>> skb_print_bits:  > headlen=114 datalen=33824 data=238 mac=238 nh=252
>> h=272 gso=1448 frag=17
>
> So the code as I had written it up should be verifying we use no more
> than 8 descriptors as that was what the data sheet states.  You might
> want to request a spec update if the hardware only supports 7 data
> descriptors per segment for a TSO as that isn't what is in the
> documentation.
>
>> skb_print_bits: frag[0]: len: 256
>> skb_print_bits: frag[1]: len: 48
>> skb_print_bits: frag[2]: len: 256
>> skb_print_bits: frag[3]: len: 48
>> skb_print_bits: frag[4]: len: 256
>> skb_print_bits: frag[5]: len: 48
>> skb_print_bits: frag[6]: len: 4096
>>
>> This descriptor ^^^ is the 8th, I believe the hardware mechanism faults on
>> this input.
>
> Is this something that was previously being linearized?  It doesn't
> seem like it would be.  We are only 8 descriptors in and that 7th
> fragment should have flushed the count back to 1 with a remainder.
>
> If you are wanting to trigger a linearize with the updated code you
> would just need to update 2 lines.  Replace "I40E_MAX_BUFFER_TXD - 1"
> with just I40E_MAX_BUFFER_TXD" in the line where we subtract that
> value from nr_frags.  Then remove one of the "sum +=
> skb_frag_size(++frag);" lines.  That should update the code so that
> you only evaluate 5 buffers at a time instead of 6.  It should force
> things to coalesce if we would span 8 or more descriptors instead of 9
> or more which is what the code currently does based on what was
> required in the EAS.
>
>> I added a print of the sum at each point it is subtracted or added to after
>> initially being set, sum7/8 are in the for loop.
>>
>> skb_print_bits: frag[7]: len: 4096
>> skb_print_bits: frag[8]: len: 48
>> skb_print_bits: frag[9]: len: 4096
>> skb_print_bits: frag[10]: len: 4096
>> skb_print_bits: frag[11]: len: 48
>> skb_print_bits: frag[12]: len: 4096
>> skb_print_bits: frag[13]: len: 4096
>> skb_print_bits: frag[14]: len: 48
>> skb_print_bits: frag[15]: len: 4096
>> skb_print_bits: frag[16]: len: 4096
>> __i40e_chk_linearize: sum1: -1399
>> __i40e_chk_linearize: sum2: -1143
>> __i40e_chk_linearize: sum3: -1095
>> __i40e_chk_linearize: sum4: -839
>> __i40e_chk_linearize: sum5: -791
>> __i40e_chk_linearize: sum7: 3305
>> __i40e_chk_linearize: sum8: 3257
>> __i40e_chk_linearize: sum7: 7353
>> __i40e_chk_linearize: sum8: 7097
>> __i40e_chk_linearize: sum7: 7145
>> __i40e_chk_linearize: sum8: 7097
>> __i40e_chk_linearize: sum7: 11193
>> __i40e_chk_linearize: sum8: 10937
>> __i40e_chk_linearize: sum7: 15033
>> __i40e_chk_linearize: sum8: 14985
>> __i40e_chk_linearize: sum7: 15033
>>
>> This was the descriptors generated from the above:
>> d[054] = 0x0000000000000000 0x16a0211400000011
>> d[055] = 0x0000000bfbaa40ee 0x000001ca02871640
>
> len 72

Minor correction here.  This is 72 hex, which is 114 in decimal.  The
interesting bit I believe is the fact that we have both header and
payload data in the same descriptor.

You should probably check with your hardware team on this but I have a
working theory on the issue.  I'm thinking that because both header
and payload are coming out of the same descriptor this must count as 2
descriptors and not 1 when we compute the usage for the first
descriptor.  As such I do probably need to start testing at frag 0
because the first payload can actually come out of the header region
if the first descriptor includes both payload and data.

I'll try to submit a patch for it tonight.  If you can test it
tomorrow I would appreciate it.  Otherwise I will try setting up an
environment to try and reproduce the issue tomorrow.

- Alex
