From: Dan Williams <dcbw@redhat.com>
Subject: Re: netlink NETLINK_ROUTE  failure & Can the kernel really handle
 IPv6 properly
Date: Thu, 02 Oct 2014 10:44:08 -0500
Message-ID: <1412264648.7227.9.camel@dcbw.local>
References: <542C63FE.9080807@emagii.com>
	 <1412199032.2532289.174101717.2D6510D0@webmail.messagingengine.com>
	 <9330C415-574C-492B-A7AE-92EBCF6D1A26@emagii.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ulf samuelsson <netdev@emagii.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27845 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752502AbaJBPoT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2014 11:44:19 -0400
In-Reply-To: <9330C415-574C-492B-A7AE-92EBCF6D1A26@emagii.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-10-02 at 14:38 +0200, Ulf samuelsson wrote:
> This is the significant code, and it is wrong.
> 
> static struct notifier_block my_ipv6_address_notifier =
>  {
>    my_ipv6_address_notifier_cb,
>    NULL,
>    0
>  };
> 
> register_inet6addr_notifier (&my_ipv6_address_notifier );
> 
> int
> my_ipv6_address_notifier_cb (struct notifier_block *self,
>                                 unsigned long event, void *val)
> {
>  struct inet6_ifaddr *ifaddr = (struct inet6_ifaddr *)val;
> 
> 
>  /* We are only interested in address add/delete events */
>  /* IPv6 address add comes as NETDEV_UP and delete comes as
>   * NETDEV_DOWN
>   */
>  if ((event != NETDEV_UP) && (event != NETDEV_DOWN))
>    return ret;
> 
>  if (ifaddr == NULL)
>    return ret;
>  /* Now that we are sure that it is a IPv6 address being added deleted,
>   * verify that it is a link local address.
>   */
>  if (!IPV6_IS_ADDR_LINKLOCAL (&ifaddr->addr))
>    {
>      return ret;
>    }
>  ...
>  send_message_to_app(LINK_LOCAL_UP, ip);
>  ...
>  return ret;
> }
> 
> 
> Application tries to send message to "ip" and fails, because the link-local adress is still
> in "tentative state"

It seems to me that a better architecture would be to have the app
itself listen for RTM_NEWADDR netlink event and look for lack of
IFA_F_TENTATIVE in the IFA_FLAGS attribute.  Using a kernel module to do
the same thing seems pretty wrong.

Dan

> Best Regards
> Ulf Samuelsson
> ulf@emagii.com
> +46  (722) 427 437
> 
> 
> > 1 okt 2014 kl. 23:30 skrev Hannes Frederic Sowa <hannes@stressinduktion.org>:
> > 
> > Hello,
> > 
> >> On Wed, Oct 1, 2014, at 22:28, Ulf Samuelsson wrote:
> >> BTW, the problem I am trying to solve is how to connect to an I/F with 
> >> an IPv6 link-local address.
> >> 
> >> An existing kernel module waits for a NETDEV_UP event, and then tries to 
> >> communicate
> >> with the link-local address.
> >> 
> >> This will fail, because (according to a colleague) the I/F enters a 
> >> "tentative" state,
> >> where it is trying to decide if it is unique or not.
> >> It will remain in that state for 1-2 seconds, and only afterwards is the 
> >> link-local address
> >> available for normal use.
> >> 
> >> The guys writing the module, claim that the kernel is using NETDEV_UP.
> >> There is very little code in the kernel using NETLINK_ROUTE, even in 
> >> latest stable.
> >> It is using NETDEV_UP.
> >> 
> >> If my colleague is right, the kernel really cannot handle IPv6 
> >> link-local addresses properly.
> > 
> > Sorry, I cannot really follow you, can you send example code or be a bit
> > more precise?
> > 
> > Thanks,
> > Hannes
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
