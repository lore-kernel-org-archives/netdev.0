From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] ip tunnel flag byte order issue
Date: Wed, 10 Oct 2012 13:34:59 -0700
Message-ID: <20121010133459.5271d091@nehalam.linuxnetplumber.net>
References: <20121010120630.5e9f2c2c@nehalam.linuxnetplumber.net>
	<1349900796.2691.32.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349900796.2691.32.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 10 Oct 2012 21:26:36 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Wed, 2012-10-10 at 12:06 -0700, Stephen Hemminger wrote:
> > Sparse found a real problem with the ABI for tunnelling.
> > 
> > The SIT and VTI tunnel ioctl's both overload the i_flags field in the
> > ip_tunnel parameters structure. This field is defined as big endian
> > (be16) and the various GRE_XXX macros do the necessary byte swapping.
> > 
> > The problem is that both SIT and VTI are using an additional flag bit
> > that is defined in host byte order, and is then or'd in. It happens to
> > work because both possible locations hit holes in the current usage of
> > GRE.  For big endian cpu's it overlaps the GRE_VERSION which is always
> > zero, and for little endian it overlaps the GRE recursion field also
> > always zero.
> 
> Why do these fields exist if they're always going to be 0?

They exist in the RFC. GRE implementation mixes bits on the wire
with bits from ioctl().

> 
> > Having the field in different places on different CPU architectures
> > was a mistake. The problem is fixing it will break the ABI on one or
> > the other architecture.  I choose to break big endian since it the
> > minority.
> 
> Or we can define the 'flag' to have both bits set (0x0101, with a
> __cpu_to_be16 to keep sparse happy) while accepting either set on input.
> 
> > Also both VTI and SIT are overloading the same bit which is an
> > accident waiting to happen.  Since VTI is newer, I propose giving a
> > different bit to VTI.
> 
> Indeed VTI is new in 3.6, so there is still a short window in which it's
> fairly safe to tweak its ABI.
> 
> > The other alternative is keeping the same ABI, but putting a big note
> > as to why it works in spite of our stupidity.
> [...]
> 
> Does it even matter that different tunnel types have different meanings
> for flags?
> 
> Ben.
> 
