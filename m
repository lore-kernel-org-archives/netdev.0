From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: removing gotos considered harmful...
Date: Wed, 3 Jan 2007 08:08:08 +0000
Message-ID: <200701030808.08182@strip-the-willow>
References: <20061222.120432.55508411.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnaldo.melo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:45034 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755007AbXACIHS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 03:07:18 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061222.120432.55508411.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

first of all - I take my hat off to such astuteness in the light of a mailing
list with an average of 100 postings per day and a massive throughput of patch
submissions. It is clearly awesome to be able to relate individual changes
in light of such a massive flood of patches.

However, I would also like to plead non-guilty. I have checked - what you
are quoting is not the original patch. If you look at e.g. 2.6.17-mm1, the 
previous code had the form (this is copied from 2.6.17-mm1 original):

			size = 0;
			sk_for_each(sk2, node, list)
				if (++size >= best_size_so_far)
					goto next;
			best_size_so_far = size;
			best = result;
		next:;

  
|  and this got converted into:
|  
|  			sk_for_each(sk2, node, head)
|  				if (++size < best_size_so_far) {
|  					best_size_so_far = size;
|  					best = result;
|  				}
|  
|  Which does something very very different from the original.
===> Sorry, I fail to see where the two differ. They have the same postcondition
     upon loop exit; sk2, node, size, and head are not referenced anywhere in the 
     code that follows.
     

  
|  Signed-off-by: David S. Miller <davem@davemloft.net>
|  
|  diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
|  index 9e1bd37..404dd21 100644
|  --- a/net/ipv4/udp.c
|  +++ b/net/ipv4/udp.c
|  @@ -167,11 +167,14 @@ int udp_get_port(struct sock *sk, unsigned short snum,
|   				goto gotit;
|   			}
|   			size = 0;
|  -			sk_for_each(sk2, node, head)
|  -				if (++size < best_size_so_far) {
|  -					best_size_so_far = size;
|  -					best = result;
|  -				}
|  +			sk_for_each(sk2, node, head) {
|  +				if (++size >= best_size_so_far)
|  +					goto next;
|  +			}
|  +			best_size_so_far = size;
|  +			best = result;
|  +		next:
|  +			;
|   		}
|   		result = best;
|   		for(i = 0; i < (1 << 16) / UDP_HTABLE_SIZE; i++, result += UDP_HTABLE_SIZE) {
|  
|  
