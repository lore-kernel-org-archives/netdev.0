From: jamal <hadi@cyberus.ca>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: 29 Dec 2004 10:53:40 -0500
Message-ID: <1104335620.1025.22.camel@jzny.localdomain>
References: <20041228192603.GE32419@postel.suug.ch>
	 <1104268498.1090.254.camel@jzny.localdomain>
	 <20041228221021.GF32419@postel.suug.ch>
	 <1104275197.1100.276.camel@jzny.localdomain>
	 <20041228231916.GG32419@postel.suug.ch>
	 <1104277165.1100.291.camel@jzny.localdomain>
	 <20041229000928.GH32419@postel.suug.ch>
	 <1104282811.1090.314.camel@jzny.localdomain>
	 <20041229124842.GI32419@postel.suug.ch>
	 <1104330054.1089.329.camel@jzny.localdomain>
	 <20041229150140.GJ32419@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041229150140.GJ32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-12-29 at 10:01, Thomas Graf wrote:
> * jamal <1104330054.1089.329.camel@jzny.localdomain> 2004-12-29 09:20
> > Given the opportunity: I think we need to put those flags as well for
> > the u32 keys(and other classifiers) so we can have similar logic?
> 
> Sounds reasonable and easy to do if we introduce a new selector TLV.

Shouldnt be and issue and both backward and forward compatible.

> Speaking of the other classifiers:
> 
> fw: Currently a list of ORed matches, nfmark transported via handle.
>     We could change it to transfer the nfmark via a TLV and implement
>     the same logic as in u32 (simple). The problem is mainly how to
>     guarantee backwards compatibility, the handle would no longer
>     tell about the nfmark being matched. OTOH, fw is no longer needed
>     once we have metadata match. Adding a "always-true" classifier with
>     ematch extension will completely replace it (except for the old
>     path with netfilter disabled).
> 

I would suspect we would end killing fwmark or it will get deprecated
for lack of use. So probably safer to leave it alone.

> tcindex: No changes required and partly replaced with metadata match
>          but not completely. It would still be perfectly fine to map
>          dscp values to classids.  
> 

This is a tricky one since it has those speacial cases.

> route4: Also partly replaced with metadata match but we would lose
>         the exellent fast paths. We can leave it as-is and have metadata
>         match for more complex matches (slow) and route4 for simple but
>         fast uses.
> 

nod.

> rsvp: Could theoretically be replaced with new u32 and extensive use
>       of continue/reclassify but that's quite difficult. It's very
>       specialized (and currently quite vulnerable to pskbs) and the use
>       of it is clearly towards fast flow redirection. No need to change
>       this.
> 
> So, the conclusion for me is that we can focus on u32 and new
> classifiers and eventually make fw obsolete in the future.
> 

Geez, I should have read to the end first ;-> So i agree with you.

> > Also in the case of u32 (to take this opportunity) i would like to stash
> > state inot a 16 bit ID to help in pretty printing the matches.
> 
> Not sure what you mean. Which "state"?
> 

One example of what state you could store:
In the case where i enter something readable in english, the display
back is raw; 
example:
match ip src 10.0.0.210/32
gets displayed as: match 0a0000d2/ffffffff at 12
And a lot of times its tricky to find exactly what "at 12" means.

If i store some ID that would tell me "IP" when i dump then i can pretty
print it in english in user space using ip_print().

> > So if we have an extra 32 bits for flags:ID probably 8 bits for your
> > need for flags, 16 bits for private Id and maybe another 8 bit for
> > something else like versioning...
> 
> Basically what I need is 3 bits for logic relations and at least 8
> for precedence index or 4 bits and reuse one of the already existing
> fields unused when key is used as container for sub keys. So, 8 bits
> will suit me very well.
> 
> +---+---+-----+
> | I | C |  R  |
> +---+---+-----+
> 
> I := 1 Match is inverted
>      0 Match is straight
> 
> C := 1 Container Key
>      0 Normal Key
> 
> R := 0 0 Last Key
>      0 1 AND
>      1 0 OR
> 
> While we're at it we should increase nkeys to 16bit.
> 

Sounds good to me since we have a new sel.
It may endup being tricky to be both fast and backward compat; but we'll
see what fun awaits when you start coding.

cheers,
jamal
