From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [patch] ixgbevf: potential NULL dereference on allocation
 failure
Date: Tue, 14 Sep 2010 09:57:46 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755F66821BC@orsmsx508.amr.corp.intel.com>
References: <20100910115234.GB5959@bicker>
 <20100910.132137.212394088.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"error27@gmail.com" <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:37587 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751492Ab0INQ5s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 12:57:48 -0400
In-Reply-To: <20100910.132137.212394088.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Friday, September 10, 2010 1:22 PM
>To: error27@gmail.com
>Cc: Rose, Gregory V; Kirsher, Jeffrey T; netdev@vger.kernel.org; kernel-
>janitors@vger.kernel.org
>Subject: Re: [patch] ixgbevf: potential NULL dereference on allocation
>failure
>
>
>That's kind of crummy semantics, if any part fails we should unwind
>and return an error.  So just do the necessary memory allocations
>first, and don't make any changes unless they all succeed.
>
>This code also seems to be incredibly racy.  It allocates the new RING
>structure, and copies the existing entries over.  Meanwhile the chip
>is still running and we're potentially processing these same ring
>entries, so by the time we actually assign adapter->{rx,tx}_ring
>pointers the contents could have changed.
>

I've taken up your suggestions and implemented them (roughly) as suggested below.  After looking at the code I had to agree that it would be very confusing for a user to set new ring parameters, have the call partially succeed but get no error and then look at the parameters again and not see what he expected.  Now the code will do as suggested and just unwind all prior allocations and return an error if the new ring sizing didn't work.  The user will be left with the prior ring size allocations which is probably what he would expect.

The patch is going to be posted internally and after it goes through our review process it will be posted to netdev.

Regards and thanks for the suggestions,

- Greg

>Probably the simplest thing to do is to structure this such that the
>chip is quiesced around the entire ring set operation, so something
>like:
>
>	tx_ring = kcalloc();
>	if (!tx_ring)
>		goto do_err;
>	rx_ring = kcalloc();
>	if (!rx_ring)
>		goto rx_ring_free_err;
>
>	ixgbevf_down(adapter);
>
>	err = setup_tx_ring(adapter, tx_ring);
>	if (err)
>		goto device_up_err;
>	err = setup_rx_ring(adapter, rx_ring);
>	if (err)
>		goto device_up_err;
>
>	ixgbevf_up(adapter);
>
>	return 0;
>
>device_up_err:
>	tear_down_tx_ring(adapter, tx_ring);
>	tear_down_rx_ring(adapter, rx_ring);
>	kfree(tx_ring);
>rx_ring_free_err:
>	kfree(rx_ring);
>do_err:
>	return err;
