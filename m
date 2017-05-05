From: David Miller <davem@davemloft.net>
Subject: bpf pointer alignment validation
Date: Fri, 05 May 2017 16:20:44 -0400 (EDT)
Message-ID: <20170505.162044.2097924822206705957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48972 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754228AbdEEUUw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 16:20:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Alexei and Daniel, I just wanted to let you guys know that I'm working
on an alignment tracker in the BPF verifier.

After trying several approaches I think what is going to work is to
maintain state like this:

1) For non-pointer registers, we record what we can prove is the
   minimum alignment of the value held in the register.

   So for example:

	r5 <<= 2

   would result in a min_align value of '4'.

   These alignment values assist us when check_packet_ptr_add() has to
   transition a pointer register and allocate an ID to it.

2) Packet pointer registers have a base alignment (which is something
   relative to NET_IP_ALIGN).

   Then there is something called an auxiliary offset alignment.

   Any time we add some non-constant value to a pointer, we apply the
   value's min alignment to the pointer register's auxiliary offset
   alignment.

Then check_pkt_ptr_alignment has it's logic adjusted such that it
takes all of this new information into account.

First, it makes the existing test:

        if ((NET_IP_ALIGN + reg->off + off) % size != 0) {

except that NET_IP_ALIGN is replaced with the packet pointer base
alignment (which we'll set in the context load helpers, thus putting
the NET_IP_ALIGN detail back into the networking code).

So that turns into something like:

        if ((reg->ptr_base_align + reg->off + off) % size != 0) {

Next, if an ID has been assigned, we have to also check the auxiliary
alignment:

	if (reg->id && (reg->aux_off_align % size) != 0) {

Otherwise, we can prove that the size access will work.

I think in order for this to work properly, we also have to stop
"forgetting" the reg->off value when we assign an ID to a pointer
register.  However, the reg->range we still have to always kill in
this situation.

Anyways, I'll play with this design and see what happens...  Feedback
is of course welcome.
