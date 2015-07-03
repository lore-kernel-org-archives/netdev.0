From: Joe Perches <joe@perches.com>
Subject: Re: [RFC patch] sctp: sctp_generate_fwdtsn: Initialize
 sctp_fwdtsn_skip array, neatening
Date: Fri, 03 Jul 2015 09:41:41 -0700
Message-ID: <1435941701.2487.71.camel@perches.com>
References: <1435874096.2487.51.camel@perches.com>
	 <20150703115105.GA3503@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0198.hostedemail.com ([216.40.44.198]:60438 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755389AbbGCQlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 12:41:45 -0400
In-Reply-To: <20150703115105.GA3503@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-07-03 at 07:51 -0400, Neil Horman wrote:
> On Thu, Jul 02, 2015 at 02:54:56PM -0700, Joe Perches wrote:
> > It's not clear to me that the sctp_fwdtsn_skip array is
> > always initialized when used.
> > 
> > It is appropriate to initialize the array to 0?
> > 
> > This patch initializes the array too 0 and moves the
> > local variables into the blocks where used.
> > 
> > It also does some miscellaneous neatening by using
> > continue; and unindenting the following block and
> > using ARRAY_SIZE rather than 10 to decouple the
> > array declaration size from a constant.
> > ---
> We don't set ftsn_skip_arr to a known value because we limit the amount of
> elements that get read from it prior to those elements being set.  That is to
> say, in our first use (the call to sctp_get_skip_pos), we pass the uninitialized
> array, and the nskips value, which is initalized to 0.  Looking at the
> definition of sctp_get_skip_pos, the for loop there becomes a nop, meaning the
> uninitalized array is irrelevant, as we never visit any of its elements.
> element zero is returned, and thats what the for_each loop in
> sctp_generate_fwdtsn sets in that element of the array.  On the next iteration
> of the for_each loop, we call sctp_get_skip_pos with nskips = 1, so only the
> first element is visited, whcih was set by the previous loop iteration.

Alright.

I might have chosen a while loop to limit the # of
returns but it likely compiles to the same code.

static inline int sctp_get_skip_pos(struct sctp_fwdtsn_skip *skiplist,
				    int nskips, __be16 stream)
{
	int i;

	for (i = 0; i < nskips; i++) {
		if (skiplist[i].stream == stream)
			return i;
	}
	return i;
}

to:

{
	int i = 0;

	while (i < nskips && skiplist[i].stream != stream)
		i++;

	return i;
}

> The rest of the cleanups look ok I think.  Can you tell me what you did to test
> it?

Just code inspection.
