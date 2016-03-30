From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next 02/16] i40e/i40evf: Rewrite logic for 8 descriptor per
 packet check
Date: Tue, 29 Mar 2016 19:20:27 -0700
Message-ID: <CAKgT0Uf8_Eb0G+k6N4vz69HefM3_oCkj7PB30z3keBCR4HAUnQ@mail.gmail.com>
References: <1455875651-21696-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1455875651-21696-3-git-send-email-jeffrey.t.kirsher@intel.com>
	<CAEuXFEwPdnh8LNMXRP6fnasXO3P-iW-k1qPciXqayY+7c6=b0w@mail.gmail.com>
	<CAEuXFEwdc1VZ6bcnMy1sqFvm=tr3zDwauW6oW8WO77F9oeERcA@mail.gmail.com>
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
Received: from mail-ig0-f171.google.com ([209.85.213.171]:34358 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751414AbcC3CU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 22:20:28 -0400
Received: by mail-ig0-f171.google.com with SMTP id sy18so19590724igc.1
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 19:20:27 -0700 (PDT)
In-Reply-To: <CAEuXFEwdc1VZ6bcnMy1sqFvm=tr3zDwauW6oW8WO77F9oeERcA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 29, 2016 at 5:34 PM, Jesse Brandeburg
<jesse.brandeburg@gmail.com> wrote:
> stupid gmail... sent again to the list, sorry for duplicate (but
> formatted better this time)
>
>
> Hey Alex, this patch appears to have caused a regression (probably both
> i40e/i40evf).  Easily reproducible running rds-stress (see the thread titled
> "i40e card Tx resets", the middle post by sowmini has the repro steps,
> ignore the pktgen discussion in the thread.)

I'll see about setting up rds tomorrow.  It should be pretty straight forward.

> I've spent some time trying to figure out the right fix, but keep getting
> stuck in the complicated logic of the function, so I'm sending this in the
> hope you'll take a look.
>
> This is (one example of) the skb that doesn't get linearized:
> skb_print_bits:  > headlen=114 datalen=33824 data=238 mac=238 nh=252
> h=272 gso=1448 frag=17

So the code as I had written it up should be verifying we use no more
than 8 descriptors as that was what the data sheet states.  You might
want to request a spec update if the hardware only supports 7 data
descriptors per segment for a TSO as that isn't what is in the
documentation.

> skb_print_bits: frag[0]: len: 256
> skb_print_bits: frag[1]: len: 48
> skb_print_bits: frag[2]: len: 256
> skb_print_bits: frag[3]: len: 48
> skb_print_bits: frag[4]: len: 256
> skb_print_bits: frag[5]: len: 48
> skb_print_bits: frag[6]: len: 4096
>
> This descriptor ^^^ is the 8th, I believe the hardware mechanism faults on
> this input.

Is this something that was previously being linearized?  It doesn't
seem like it would be.  We are only 8 descriptors in and that 7th
fragment should have flushed the count back to 1 with a remainder.

If you are wanting to trigger a linearize with the updated code you
would just need to update 2 lines.  Replace "I40E_MAX_BUFFER_TXD - 1"
with just I40E_MAX_BUFFER_TXD" in the line where we subtract that
value from nr_frags.  Then remove one of the "sum +=
skb_frag_size(++frag);" lines.  That should update the code so that
you only evaluate 5 buffers at a time instead of 6.  It should force
things to coalesce if we would span 8 or more descriptors instead of 9
or more which is what the code currently does based on what was
required in the EAS.

> I added a print of the sum at each point it is subtracted or added to after
> initially being set, sum7/8 are in the for loop.
>
> skb_print_bits: frag[7]: len: 4096
> skb_print_bits: frag[8]: len: 48
> skb_print_bits: frag[9]: len: 4096
> skb_print_bits: frag[10]: len: 4096
> skb_print_bits: frag[11]: len: 48
> skb_print_bits: frag[12]: len: 4096
> skb_print_bits: frag[13]: len: 4096
> skb_print_bits: frag[14]: len: 48
> skb_print_bits: frag[15]: len: 4096
> skb_print_bits: frag[16]: len: 4096
> __i40e_chk_linearize: sum1: -1399
> __i40e_chk_linearize: sum2: -1143
> __i40e_chk_linearize: sum3: -1095
> __i40e_chk_linearize: sum4: -839
> __i40e_chk_linearize: sum5: -791
> __i40e_chk_linearize: sum7: 3305
> __i40e_chk_linearize: sum8: 3257
> __i40e_chk_linearize: sum7: 7353
> __i40e_chk_linearize: sum8: 7097
> __i40e_chk_linearize: sum7: 7145
> __i40e_chk_linearize: sum8: 7097
> __i40e_chk_linearize: sum7: 11193
> __i40e_chk_linearize: sum8: 10937
> __i40e_chk_linearize: sum7: 15033
> __i40e_chk_linearize: sum8: 14985
> __i40e_chk_linearize: sum7: 15033
>
> This was the descriptors generated from the above:
> d[054] = 0x0000000000000000 0x16a0211400000011
> d[055] = 0x0000000bfbaa40ee 0x000001ca02871640

len 72

> d[056] = 0x0000000584bcd000 0x0000040202871640

len 256

> d[057] = 0x0000000c0bfea9d0 0x000000c202871640

len 48

> d[058] = 0x0000000584bcd100 0x0000040202871640

len 256

> d[059] = 0x0000000c0bfeaa00 0x000000c202871640

len 48

> d[05a] = 0x0000000584bcd200 0x0000040202871640

len 256

> d[05b] = 0x0000000c0bfeaa30 0x000000c202871640

len 48

> d[05c] = 0x000000056d5f0000 0x0000400202871640

len 4096

>From what I can see we are at 8 descriptors and have exceeded 1 MSS.
According to the EAS this is supposed to work.

> d[05d] = 0x000000056d5f1000 0x0000400202871640
> d[05e] = 0x0000000c0bfeaa60 0x000000c202871640
> d[05f] = 0x00000005f2762000 0x0000400202871640
> d[060] = 0x00000005f765e000 0x0000400202871640
> d[061] = 0x0000000c0bfeaa90 0x000000c202871640
> d[062] = 0x0000000574928000 0x0000400202871640
> d[063] = 0x0000000568ba5000 0x0000400202871640
> d[064] = 0x0000000c0bfeaac0 0x000000c202871640
> d[065] = 0x00000005f68cd000 0x0000400202871640
> d[066] = 0x0000000585a2a000 0x0000400202871670
>
>
> On Fri, Feb 19, 2016 at 3:54 AM Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> wrote:
>>
>> From: Alexander Duyck <aduyck@mirantis.com>
>>
>> This patch is meant to rewrite the logic for how we determine if we can
>> transmit the frame or if it needs to be linearized.
>>
>> +       /* Initialize size to the negative value of gso_size minus 1.  We
>> +        * use this as the worst case scenerio in which the frag ahead
>> +        * of us only provides one byte which is why we are limited to 6
>> +        * descriptors for a single transmit as the header and previous
>> +        * fragment are already consuming 2 descriptors.
>> +        */
>> +       sum = 1 - gso_size;
>> +
>> +       /* Add size of frags 1 through 5 to create our initial sum */
>> +       sum += skb_frag_size(++frag);
>
>
> I'm pretty sure this code skips frag[0] due to the pre-increment, the bug
> seems to occur in the algorithm because skb->data contains L2/L3/L4 header
> plus some data, and should counts as 1 descriptor for every subsequent sent
> packet, and if the incoming skb has 7 chunks that add up to < MSS then we
> get in trouble.

Yep we were skipping frag 0 on purpose.  There is a comment earlier
that basically states that frag 0 cannot borrow from an earlier
descriptor.  The assumption is that if we have a frag it contains at
least 1 byte.  So if the 6 frags following the first one do not
provide at least gso_size - 1 in data the packet needs to be
linearized.

The code as written was meant to cap us at 8 data descriptors per
packet.  It sounds like we are wanting to reduce that to 7 if I
understand what you are describing correctly.

>> +       sum += skb_frag_size(++frag);
>> +       sum += skb_frag_size(++frag);
>> +       sum += skb_frag_size(++frag);
>> +       sum += skb_frag_size(++frag);
>> +
>> +       /* Walk through fragments adding latest fragment, testing it, and
>> +        * then removing stale fragments from the sum.
>> +        */
>> +       stale = &skb_shinfo(skb)->frags[0];
>> +       for (;;) {
>> +               sum += skb_frag_size(++frag);
>> +
>> +               /* if sum is negative we failed to make sufficient progress */
>> +               if (sum < 0)
>> +                       return true;
>> +
>> +               /* use pre-decrement to avoid processing last fragment */
>> +               if (!--nr_frags)
>> +                       break;
>> +
>> +               sum -= skb_frag_size(++stale);
>
>
> I think this line also skips stale[0]

Right we skip frag 0 and the last fragment in the packet.  The general
idea was that we were preventing us from going over 8 descriptors per
packet so I was only checking 6 fragments starting at the second and
as long as we completed one MSS in those 6 descriptors we were
guaranteed to complete a packet in less than 8 total descriptors.
