From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [PATCH v2] xen-netfront: pull on receive skb may need to
 happen earlier
Date: Tue, 16 Jul 2013 12:26:50 +0100
Message-ID: <51E54A1A02000078000E557C@nat28.tlf.novell.com>
References: <51E5327902000078000E5426@nat28.tlf.novell.com>
 <20130716102524.GC5674@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Ian Campbell" <ian.campbell@citrix.com>, <davem@davemloft.net>,
	"Dion Kant" <g.w.kant@hunenet.nl>,
	"xen-devel" <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <stable@vger.kernel.org>
To: "Wei Liu" <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:42958 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932075Ab3GPL0z convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:5:1>);
	Tue, 16 Jul 2013 07:26:55 -0400
In-Reply-To: <20130716102524.GC5674@zion.uk.xensource.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 16.07.13 at 12:25, Wei Liu <wei.liu2@citrix.com> wrote:
> On Tue, Jul 16, 2013 at 10:46:01AM +0100, Jan Beulich wrote:
>> Due to commit 3683243b ("xen-netfront: use __pskb_pull_tail to ensure
>> linear area is big enough on RX") xennet_fill_frags() may end up
>> filling MAX_SKB_FRAGS + 1 fragments in a receive skb, and only reduce
>> the fragment count subsequently via __pskb_pull_tail(). That's a
>> result of xennet_get_responses() allowing a maximum of one more slot to
>> be consumed (and intermediately transformed into a fragment) if the
>> head slot has a size less than or equal to RX_COPY_THRESHOLD.
>> 
>> Hence we need to adjust xennet_fill_frags() to pull earlier if we
>> reached the maximum fragment count - due to the described behavior of
>> xennet_get_responses() this guarantees that at least the first fragment
>> will get completely consumed, and hence the fragment count reduced.
>> 
>> In order to not needlessly call __pskb_pull_tail() twice, make the
>> original call conditional upon the pull target not having been reached
>> yet, and defer the newly added one as much as possible (an alternative
>> would have been to always call the function right before the call to
>> xennet_fill_frags(), but that would imply more frequent cases of
>> needing to call it twice).
>> 
>> Signed-off-by: Jan Beulich <jbeulich@suse.com>
>> Cc: Wei Liu <wei.liu2@citrix.com>
>> Cc: Ian Campbell <ian.campbell@citrix.com>
>> Cc: stable@vger.kernel.org (3.6 onwards)
>> ---
>> v2: Use skb_add_rx_frag() to keep all accounting fields up to date as
>>     we go (skb->len needing intermediate updating was pointed out by
>>     Wei Liu and David Miller, shinfo->nr_frags needing updating before
>>     calling __pskb_pull_tail() was spotted out by Dion Kant).
> 
> Jan and Dion, is this a confirmed fix for SuSE kernel?
> 
> I complied and tested it, at least it didn't break things for me. The
> tests I ran were 1) scp large_file to domU; 2) iperf from Dom0 to DomU;
> 3) netperf from Dom0 to DomU.

Yes, the equivalent of this applied to our driver fixes the issue
for Dion.

Jan
