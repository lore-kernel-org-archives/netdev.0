From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: PMTU discovery is broken on kernel 3.7.1 for UDP sockets
Date: Wed, 19 Dec 2012 13:35:19 +0000
Message-ID: <1355924119.2676.6.camel@bwh-desktop.uk.solarflarecom.com>
References: <50D1BCC0.2000208@oktetlabs.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>
To: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:7304 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753221Ab2LSNfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 08:35:23 -0500
In-Reply-To: <50D1BCC0.2000208@oktetlabs.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-12-19 at 17:10 +0400, Yurij M. Plotnikov wrote:
> On kernel 3.7.1 I get strange behaviour of IP_MTU_DISCOVER socket 
> option. The behaviour in case of IP_PMTUDISC_DO and IP_PMTUDISC_WANT 
> values of IP_MTU_DISCOVER socket option on SOCK_DGRAM socket are the 
> same and packet is always sent with "Don't Fragment" bit in case of 
> IP_PMTUDISC_WANT. Also, the value of IP_MTU socket option is not updated.

You could try reverting:

commit ee9a8f7ab2edf801b8b514c310455c94acc232f6
Author: Steffen Klassert <steffen.klassert@secunet.com>
Date:   Mon Oct 8 00:56:54 2012 +0000

    ipv4: Don't report stale pmtu values to userspace
    
    We report cached pmtu values even if they are already expired.
    Change this to not report these values after they are expired
    and fix a race in the expire time calculation, as suggested by
    Eric Dumazet.

Still, PMTU information is not supposed to expire for 10 minutes...

[...]
> On eth2 on host_B and on eth1 on host_C change MTU from 1500 to 750. 
> Wait for a while.
> 
> 9. send(6, lenght=1400) -> 1400 // the packet is sent with "Don't 
> Fragment" bit, tcpdump on eth1 on host_B shows it
> 10. sleep(5);
> 11. send(6, length=1400) -> -1 with EMSGSIZE
> 12. sleep(5);
> 13. getsockopt(6,IP_MTU) -> 0 // Returns that MTU is 1500 once again. So 
> value is not updated.
[...]

What if you read this option immediately before the sleep(5)?

Ben.
