From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: e1000_xmit_frame and e1000_down racing  with next_to_use?
Date: Wed, 6 Sep 2006 11:13:25 -0700
Message-ID: <20060906111325.7acab51a@localhost.localdomain>
References: <4348.38.114.160.126.1157565495.squirrel@webmail.vranix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:14504 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751481AbWIFSNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 14:13:32 -0400
To: shaw@vranix.com
In-Reply-To: <4348.38.114.160.126.1157565495.squirrel@webmail.vranix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 6 Sep 2006 10:58:15 -0700 (PDT)
shaw@vranix.com wrote:

> Hello All,
> 
> I have a question about the use of the tx_ring->next_to_use variable in
> the e1000.  Specifically, I'm wondering about a race between the use of
> next_to_use in e1000_xmit_frame and the clearing of next_to_use in
> e1000_down via e1000_clean_tx_ring.
> 
> Thread 1 (_xmit) ->  first = adapter->tx_ring.next_to_use;
>                      e1000_tx_map();
> Thread 2 (_down) ->  e1000_clean_tx_ring();
>                      tx_ring->next_to_use = 0;
> Thread 1 (_xmit) -> e1000_tx_queue();
> 
> It seems that tx_ring.next_to_use could change between the time the skbuff
> is mapped in e1000_tx_map and the time it is reported to the hardware in
> e1000_tx_queue.  While I don't see any memory leaks or possible oops, it
> does seem possible that that an skbuff could be "lost" in the ring as it
> will not be queued in the subsequent e1000_queue.
> 
> If the race is possible, perhaps this could be the culprit behind the tx
> timeouts we've seen reported in this list?  The watchdog will eventually
> find the "lost" skbuff and mistakenly think that the hardware transmit has
> hung and stop the queue.
> 
> Could one of you plese tell me how this race is avoided, if indeed it is?
> 
> Thanks,
> Shaw
> 

e1000_down calls netif_stop_queue() and that stops transmit requests.
It doesn't handle the case of a transmit in flight during the e1000_down.

Shouldn't clean_tx_ring acquire tx_ring->tx_lock to avoid that?


-- 
Stephen Hemminger <shemminger@osdl.org>
