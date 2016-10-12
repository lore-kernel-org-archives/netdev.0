From: Luca Coelho <luca@coelho.fi>
Subject: Re: [PATCH] iwlwifi: pcie: reduce "unsupported splx" to a warning
Date: Wed, 12 Oct 2016 09:11:59 +0300
Message-ID: <1476252719.7776.6.camel@coelho.fi>
References: <20161010071943.4717-1-chris@rorvick.com>
         <1476108164.5210.11.camel@coelho.fi> <1476180668.17022.21.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>, Chris Rorvick <chris@rorvick.com>,
        Intel Linux Wireless <linuxwifi@intel.com>,
        Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Oren Givon <oren.givon@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from paleale.coelho.fi ([176.9.41.70]:48288 "EHLO
        farmhouse.coelho.fi" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752481AbcJLGMq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 02:12:46 -0400
In-Reply-To: <1476180668.17022.21.camel@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Paul,
On Tue, 2016-10-11 at 12:11 +0200, Paul Bolle wrote:
> On Mon, 2016-10-10 at 17:02 +0300, Luca Coelho wrote:
> > On Mon, 2016-10-10 at 02:19 -0500, Chris Rorvick wrote:
> > This is not coming from the NIC itself, but from the platform's ACPI
> > tables.  Can you tell us which platform you are using?
> 
> 
> On my machine I'm seeing the same error as Chris. So what exactly do
> you mean with "platform" here?

By "platform" I meant the PC you are using.  The ACPI table is created
by the OEM, so different PCs have different tables.


> 
> > >         Name (SPLX, Package (0x04)
> > >         {
> > >             Zero,
> > >             Package (0x03)
> > >             {
> > >                 0,
> > >                 1200,
> > >                 1000
> > >             },
> > >             Package (0x03)
> > >             {
> > >                 0,
> > >                 1200,
> > >                 1000
> > >             },
> > >             Package (0x03)
> > >             {
> > >                 0,
> > >                 1200,
> > >                 1000
> > >             }
> > >         })
> > 
> > 
> > This is not the structure that we are expecting.  We expect this:
> > 
> >                Name (SPLX, Package (0x02)
> >                {
> >                    Zero,
> >                    Package (0x03)
> >                    {
> >                        0x07,
> >                        <value>,
> >                        <value>
> >                    }
> >                })
> > 
> > ...as you correctly pointed out.  The data in the structure you have is
> > not for WiFi (actually I don't think 0 is a valid value, but I'll
> > double-check).
> 
> 
> For what it's worth, on my machine I have twenty (!) SPLX entries, all
> reading:
>     Name (SPLX, Package (0x04)
>     {
>         Zero, 
>         Package (0x03)
>         {
>             0x80000000, 
>             0x80000000, 
>             0x80000000
>         }, 
>     
>         Package (0x03)
>         {
>            0x80000000, 
>            0x80000000, 
>            0x80000000
>         }, 
>     
>         Package (0x03)
>         {
>             0x80000000, 
>             0x80000000, 
>             0x80000000
>         }
>     })

Thanks.  So this is another case where the first value doesn't match
what we are expecting and we should just ignore that.


> > There are other things that look a bit inconsistent in this code...
> > I'll try to find the official ACPI table definitions for this entries
> > to make sure it's correct.
> 
> 
> When I looked into this error, some time ago, I searched around a bit
> for documentation on this splx stuff. Sadly, commit bcb079a14d75
> ("iwlwifi: pcie: retrieve and parse ACPI power limitations") provides
> very few clues and my searches turned up nothing useful. So a pointer
> or two would be really appreciated.

Yeah, I looked into that commit too and there's not much there.  I'll
try to find the documentation and, if I can, I'll share it with you.


> > > --- a/drivers/net/wireless/intel/iwlwifi/pcie/drv.c
> > > +++ b/drivers/net/wireless/intel/iwlwifi/pcie/drv.c
> > > @@ -540,7 +540,7 @@ static u64 splx_get_pwr_limit(struct iwl_trans *trans, union acpi_object *splx)
> > >  	    splx->package.count != 2 ||
> > >  	    splx->package.elements[0].type != ACPI_TYPE_INTEGER ||
> > >  	    splx->package.elements[0].integer.value != 0) {
> > > -		IWL_ERR(trans, "Unsupported splx structure\n");
> > > +		IWL_WARN(trans, "Unsupported splx structure, not limiting WiFi power\n");
> > >  		return 0;
> > >  	}
> > 
> > 
> > If this is really bothering you, I guess I could apply this patch for
> > now.  But as I said, this is not solving the actual problem.
> 
> 
> Bikeshedding: I think IWL_INFO() is more appropriate, as info doesn't
> imply one needs to act on this message, while warn does imply that
> action is needed.

Right, but in fact, the code considers that if the SPLX method exists,
it must return a value iwlwifi can understand, thus the error.  That
assumption is wrong, so we should just ignore entries that don't match
and continue without printing anything out (as would happen if the splx
method were not even there).

In any case, I will rework this code, so I'd prefer if we skip this
patch entirely.
