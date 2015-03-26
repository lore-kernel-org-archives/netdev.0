From: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Subject: Re: [PATCH 0/2 RESEND] IB/Verbs: Use helpers to refine the checking
 on transport and link layer
Date: Thu, 26 Mar 2015 17:04:13 +0100
Message-ID: <55142DFD.2060100@profitbricks.com>
References: <5512CFB0.1050108@profitbricks.com> <1427378940.21101.100.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Tatyana Nikolova <Tatyana.E.Nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Yan Burman <yanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>,
	Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Dan Carpenter <dan.carpenter@o
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1427378940.21101.100.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi, Doug

Thanks for the excellent comments :-)

On 03/26/2015 03:09 PM, Doug Ledford wrote:
> On Wed, 2015-03-25 at 16:09 +0100, Michael Wang wrote:
>> [snip]
>>
> [snip]
>
> So, I would suggest that we fix things up thusly:
>
> enum transport {
> 	TRANSPORT_IB=1,
> 	TRANSPORT_IWARP=2,
> 	TRANSPORT_ROCE=4,
> 	TRANSPORT_OPA=8,
> 	TRANSPORT_USNIC=10,
> };
>
> #define HAS_SA(ibdev) ((ibdev)->transport & (TRANSPORT_IB|TRANSPORT_OPA))
> #define HAS_JUMBO_SA(ibdev) ((ibdev)->transport & TRANSPORT_OPA))
>
> or possibly
>
> static bool ib_dev_has_sa(struct ibv_device *ibdev)
> {
> 	return ibdev->transport & (TRANSPORT_IB | TRANSPORT_OPA);
> }

The idea sounds interesting, and here my silly questions come :-P

So are you suggesting that we add a new bitmask 'transport' into 'struct ib_device'
in kernel, and setup it at very beginning?

Few more questions here is:
1. when to setup? (maybe inside ib_register_device() before doing client->add() callback?)

2. how to setup? (still infer from the transport and link layer like we currently do?)

3. in case if a device has ports with different link layer type (please correct
    me if this will never happen), then only one bitmask may not be enough to
    present the transport of all the ports? (maybe create a bitmask per port?)

Regards,
Michael Wang

>
> If we do this, then the only thing we have to fix up to preserve ABI
> with user space is to make sure that any time we export an ibv_device
> struct and any time we import the same, we convert from our new internal
> representation to the old representation that user space expects.  And
> we also need to make a few changes in the sysfs code to display the
> properties as things expect.  But, that would allow us to fix up what I
> see as a problem right now, which is that we hide the information we
> need to know what sort of device we are working on in two different
> fields: the transport and the link layer.  Instead, just use one field
> with enough variants that we can store all of the relevant information
> we need in that one field.  This has the benefit that any comparisons
> that happen in hot paths will now always be a single bitwise comparison
> and will no longer need to hit two separate variables for two separate
> compares.
>
>
>

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
