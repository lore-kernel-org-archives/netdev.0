From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH] net: dsa: loop: Check for memory allocation failure
Date: Tue, 9 May 2017 08:39:43 +0800 (SGT)
Message-ID: <alpine.DEB.2.20.1705090839270.3309@hadrien>
References: <20170506052945.2639-1-christophe.jaillet@wanadoo.fr> <063D6719AE5E284EB5DD2968C1650D6DCFFE715E@AcuExch.aculab.com> <alpine.DEB.2.20.1705082031280.3440@hadrien> <1494265443.31950.62.camel@perches.com> <alpine.DEB.2.20.1705090745190.3309@hadrien>
 <f9058de7-ef9e-f6eb-751d-72ffdce512bb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Joe Perches <joe@perches.com>,
        David Laight <David.Laight@ACULAB.COM>,
        'Christophe JAILLET' <christophe.jaillet@wanadoo.fr>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "vivien.didelot@savoirfairelinux.com"
        <vivien.didelot@savoirfairelinux.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f9058de7-ef9e-f6eb-751d-72ffdce512bb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 8 May 2017, Florian Fainelli wrote:

> On 05/08/2017 04:46 PM, Julia Lawall wrote:
> >
> >
> > On Mon, 8 May 2017, Joe Perches wrote:
> >
> >> On Mon, 2017-05-08 at 20:32 +0800, Julia Lawall wrote:
> >>>
> >>> On Mon, 8 May 2017, David Laight wrote:
> >>>
> >>>> From: Christophe JAILLET
> >>>>> Sent: 06 May 2017 06:30
> >>>>> If 'devm_kzalloc' fails, a NULL pointer will be dereferenced.
> >>>>> Return -ENOMEM instead, as done for some other memory allocation just a
> >>>>> few lines above.
> >>>>
> >>>> ...
> >>>>> --- a/drivers/net/dsa/dsa_loop.c
> >>>>> +++ b/drivers/net/dsa/dsa_loop.c
> >>>>> @@ -256,6 +256,9 @@ static int dsa_loop_drv_probe(struct mdio_device *mdiodev)
> >>>>>  		return -ENOMEM;
> >>>>>
> >>>>>  	ps = devm_kzalloc(&mdiodev->dev, sizeof(*ps), GFP_KERNEL);
> >>>>> +	if (!ps)
> >>>>> +		return -ENOMEM;
> >>>>> +
> >>>>>  	ps->netdev = dev_get_by_name(&init_net, pdata->netdev);
> >>>>>  	if (!ps->netdev)
> >>>>>  		return -EPROBE_DEFER;
> >>>>
> >>>> On the face if it this code leaks like a sieve.
> >>>
> >>> I don't think so.  The allocations (dsa_switch_alloc and devm_kzalloc) use
> >>> devm functions.
> >>
> >> It's at least wasteful.
> >>
> >> Each time -EPROBE_DEFER occurs, another set of calls to
> >> dsa_switch_alloc and dev_kzalloc also occurs.
> >>
> >> Perhaps it'd be better to do:
> >>
> >> 	if (ps->netdev) {
> >> 		devm_kfree(&devmdev->dev, ps);
> >> 		devm_kfree(&mdiodev->dev, ds);
> >> 		return -EPROBE_DEFER;
> >> 	}
> >
> > Is EPROBE_DEFER handled differently than other kinds of errors?
>
> In the core device driver model, yes, EPROBE_DEFER is treated
> differently than other errors because it puts the driver on a retry queue.
>
> EPROBE_DEFER is already a slow and exceptional path, and this is a
> mock-up driver, so I am not sure what value there is in trying to
> balance devm_kzalloc() with corresponding devm_kfree()...

OK, thanks for the explanation.

julia
