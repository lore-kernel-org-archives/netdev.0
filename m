From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: Wed, 29 Dec 2004 16:01:40 +0100
Message-ID: <20041229150140.GJ32419@postel.suug.ch>
References: <20041228192603.GE32419@postel.suug.ch> <1104268498.1090.254.camel@jzny.localdomain> <20041228221021.GF32419@postel.suug.ch> <1104275197.1100.276.camel@jzny.localdomain> <20041228231916.GG32419@postel.suug.ch> <1104277165.1100.291.camel@jzny.localdomain> <20041229000928.GH32419@postel.suug.ch> <1104282811.1090.314.camel@jzny.localdomain> <20041229124842.GI32419@postel.suug.ch> <1104330054.1089.329.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Patrick McHardy <kaber@trash.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104330054.1089.329.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1104330054.1089.329.camel@jzny.localdomain> 2004-12-29 09:20
> Given the opportunity: I think we need to put those flags as well for
> the u32 keys(and other classifiers) so we can have similar logic?

Sounds reasonable and easy to do if we introduce a new selector TLV.
Speaking of the other classifiers:

fw: Currently a list of ORed matches, nfmark transported via handle.
    We could change it to transfer the nfmark via a TLV and implement
    the same logic as in u32 (simple). The problem is mainly how to
    guarantee backwards compatibility, the handle would no longer
    tell about the nfmark being matched. OTOH, fw is no longer needed
    once we have metadata match. Adding a "always-true" classifier with
    ematch extension will completely replace it (except for the old
    path with netfilter disabled).

tcindex: No changes required and partly replaced with metadata match
         but not completely. It would still be perfectly fine to map
         dscp values to classids.  

route4: Also partly replaced with metadata match but we would lose
        the exellent fast paths. We can leave it as-is and have metadata
        match for more complex matches (slow) and route4 for simple but
        fast uses.

rsvp: Could theoretically be replaced with new u32 and extensive use
      of continue/reclassify but that's quite difficult. It's very
      specialized (and currently quite vulnerable to pskbs) and the use
      of it is clearly towards fast flow redirection. No need to change
      this.

So, the conclusion for me is that we can focus on u32 and new
classifiers and eventually make fw obsolete in the future.

> Also in the case of u32 (to take this opportunity) i would like to stash
> state inot a 16 bit ID to help in pretty printing the matches.

Not sure what you mean. Which "state"?

> So if we have an extra 32 bits for flags:ID probably 8 bits for your
> need for flags, 16 bits for private Id and maybe another 8 bit for
> something else like versioning...

Basically what I need is 3 bits for logic relations and at least 8
for precedence index or 4 bits and reuse one of the already existing
fields unused when key is used as container for sub keys. So, 8 bits
will suit me very well.

+---+---+-----+
| I | C |  R  |
+---+---+-----+

I := 1 Match is inverted
     0 Match is straight

C := 1 Container Key
     0 Normal Key

R := 0 0 Last Key
     0 1 AND
     1 0 OR

While we're at it we should increase nkeys to 16bit.
