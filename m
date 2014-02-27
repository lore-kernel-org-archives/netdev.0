From: Ben Greear <greearb@candelatech.com>
Subject: Re: How to best consolidate list of skbs (msdu) for receive?
Date: Thu, 27 Feb 2014 13:51:04 -0800
Message-ID: <530FB348.2070701@candelatech.com>
References: <530F85AE.8060002@candelatech.com>  <CAGVrzcajmuGQRi84WqWrxyUK2+xG1+b7EMTwRk4WpsDnp0B7qQ@mail.gmail.com> <1393536113.26794.41.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57443 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979AbaB0VvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 16:51:06 -0500
In-Reply-To: <1393536113.26794.41.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/27/2014 01:21 PM, Eric Dumazet wrote:
> On Thu, 2014-02-27 at 12:37 -0800, Florian Fainelli wrote:
>> 2014-02-27 10:36 GMT-08:00 Ben Greear <greearb@candelatech.com>:
>>> In ath10k, it can receive msdu (in rx raw mode, at least).  These show up
>>> as a list of skb.  Currently they are just dropped as un-handled, and I
>>> need to fix this.
>>>
>>> I think I need to consolidate this list into a single skb in order to pass
>>> it up the stack.
>>>
>>> What is the preferred way to go about doing this?
>>>
>>> It seems I could just expand the head skb (pskb_expand_head) and copy the data from the others
>>> onto the end of the head skb, but maybe there is a more efficient way to go about
>>> doing this?
>>
>> Some Ethernet drivers you would in general get multiple RX fragments
>> for large frames, with the first fragment containing the headers, and
>> then buffers of a few KiB, it is the driver responsibility to
>> reassemble this as a large SKB with multiple fragments (grep for
>> skb_fill_page_desc), would that work in your case?
> 
> Also skb_try_coalesce() might feet the need, if all you have are a list
> of skb, rather than an array of page fragments

Thanks for the hints...I'll go look at this.

That said, the code below appears to work, even if it is
not as efficient as it might be?

			if (msdu_chaining) {
				struct sk_buff *next = msdu_head->next;
				struct sk_buff *to_free = next;
				int space;
				static int do_once = 1;
				msdu_head->next = NULL;

				if (unlikely(do_once)) {
					ath10k_warn("htt rx msdu_chaining detected %d\n",
						    msdu_chaining);
					do_once = 0;
				}

				while (next) {
					space = next->len - skb_tailroom(msdu_head);

					if ((space > 0) &&
					    (pskb_expand_head(msdu_head, 0, space, GFP_ATOMIC) < 0)) {
						/* TODO:  bump some rx-oom error stat */
						goto outside_continue;
					}
					skb_copy_from_linear_data(next, skb_put(msdu_head, next->len),
								  next->len);
					next = next->next;
				}

				/* If here, we have consolidated skb.  Free the
				 * fragments and pass the main skb on up the
				 * stack.
				 */
				ath10k_htt_rx_free_msdu_chain(to_free);
				goto have_good_msdu;

			outside_continue:
				/* put it back together so we can free the
				 * whole list at once.
				 */
				msdu_head->next = to_free;
				ath10k_htt_rx_free_msdu_chain(msdu_head);
				continue;
			}



Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
