From: Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>
Subject: Re: [PATCH] iwlwifi: pcie: reduce "unsupported splx" to a warning
Date: Tue, 11 Oct 2016 12:11:08 +0200
Message-ID: <1476180668.17022.21.camel@tiscali.nl>
References: <20161010071943.4717-1-chris@rorvick.com>
         <1476108164.5210.11.camel@coelho.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Luca Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>, Chris Rorvick <chris-FAYdYWbMHyxBDgjK7y7TUQ@public.gmane.org>,
        Intel Linux Wireless <linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Oren Givon <oren.givon-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476108164.5210.11.camel-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Luca,

On Mon, 2016-10-10 at 17:02 +0300, Luca Coelho wrote:
> On Mon, 2016-10-10 at 02:19 -0500, Chris Rorvick wrote:
> This is not coming from the NIC itself, but from the platform's ACPI
> tables.  Can you tell us which platform you are using?

On my machine I'm seeing the same error as Chris. So what exactly do
you mean with "platform" here?

> >         Name (SPLX, Package (0x04)
> >         {
> >             Zero,
> >             Package (0x03)
> >             {
> >                 0,
> >                 1200,
> >                 1000
> >             },
> >             Package (0x03)
> >             {
> >                 0,
> >                 1200,
> >                 1000
> >             },
> >             Package (0x03)
> >             {
> >                 0,
> >                 1200,
> >                 1000
> >             }
> >         })
> 
> This is not the structure that we are expecting.  We expect this:
> 
>                Name (SPLX, Package (0x02)
>                {
>                    Zero,
>                    Package (0x03)
>                    {
>                        0x07,
>                        <value>,
>                        <value>
>                    }
>                })
> 
> ...as you correctly pointed out.  The data in the structure you have is
> not for WiFi (actually I don't think 0 is a valid value, but I'll
> double-check).

For what it's worth, on my machine I have twenty (!) SPLX entries, all
reading:
    Name (SPLX, Package (0x04)
    {
        Zero, 
        Package (0x03)
        {
            0x80000000, 
            0x80000000, 
            0x80000000
        }, 
    
        Package (0x03)
        {
           0x80000000, 
           0x80000000, 
           0x80000000
        }, 
    
        Package (0x03)
        {
            0x80000000, 
            0x80000000, 
            0x80000000
        }
    })

> There are other things that look a bit inconsistent in this code...
> I'll try to find the official ACPI table definitions for this entries
> to make sure it's correct.

When I looked into this error, some time ago, I searched around a bit
for documentation on this splx stuff. Sadly, commit bcb079a14d75
("iwlwifi: pcie: retrieve and parse ACPI power limitations") provides
very few clues and my searches turned up nothing useful. So a pointer
or two would be really appreciated.

> > --- a/drivers/net/wireless/intel/iwlwifi/pcie/drv.c
> > +++ b/drivers/net/wireless/intel/iwlwifi/pcie/drv.c
> > @@ -540,7 +540,7 @@ static u64 splx_get_pwr_limit(struct iwl_trans *trans, union acpi_object *splx)
> >  	    splx->package.count != 2 ||
> >  	    splx->package.elements[0].type != ACPI_TYPE_INTEGER ||
> >  	    splx->package.elements[0].integer.value != 0) {
> > -		IWL_ERR(trans, "Unsupported splx structure\n");
> > +		IWL_WARN(trans, "Unsupported splx structure, not limiting WiFi power\n");
> >  		return 0;
> >  	}
> 
> If this is really bothering you, I guess I could apply this patch for
> now.  But as I said, this is not solving the actual problem.

Bikeshedding: I think IWL_INFO() is more appropriate, as info doesn't
imply one needs to act on this message, while warn does imply that
action is needed.

Thanks,


Paul Bolle
