From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] cfg80211 and nl80211
Date: Wed, 04 Oct 2006 09:41:13 +0200
Message-ID: <1159947674.2817.19.camel@ux156>
References: <1159435399.2648.17.camel@ux156>
	 <1159805711.2834.67.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:1990 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030531AbWJDHkZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 03:40:25 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1159805711.2834.67.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-10-02 at 12:15 -0400, Dan Williams wrote:

> I'm not sure what you mean here.  Do you really mean "grab the current
> _cmdlist_"?  Because I'm not sure how grabbing the current configuration
> (using GET_CONFIG) would necessarily return the right set of options for
> the device.  Also, what do you mean by "is supposed to be complete
> then"?

Yeah, I was thinking GET_CONFIG would fill in all values that you can
also set. But then again, if no SSID was ever set it can't fill in an
SSID, so that's bogus. We'll need to add a command to return a bitmask
of what parameters a card supports.

> On large problem we had with WPA was that there was _no_ way to tell
> whether or not a driver supported it.  Trying a WPA-related ioctl() and
> hoping for the best is broken.  On the one hand, there were users
> screaming that yes, Madwifi did in fact support WPA, but of course,
> there was no standard way of figuring that out and present it to the
> user in a sane manner.  We need to have an _explicit_ list of stuff that
> driver does and does not support so that intelligent decisions can be
> made before and/or without touching stuff that might turn the radio on
> or mess up an existing configuration set by somebody else.

Right. Though with WPA, that's likely going to be in a few special
commands, so checking if the driver supports those commands (by getting
the command list) ought to be enough, no?

> Does "parameters" here mean CMD or ATTR? 

ATTR. Unknown commands are rejected anyway right in the genetlink layer
(afaik), the question was just whether to ignore or reject attributes we
don't understand.

>  In any case, there's a good
> case to be made for rejecting unsupported CMDs & ATTRs.  If the user,
> for example, wishes to restrict the roaming to a set of BSSIDs for
> security measures, for example (even if an insecure one), but the driver
> doesn't support that, should nl80211 just blindly pretend that it
> worked?  This might also get people to fix up their drivers and
> userspace programs too.

Good point. However, I'd think that such a feature could well have a new
command like CMD_SET_RESTRICTED_BSSID_LIST with a BSSID_LIST attribute,
and then the whole problem doesn't really happen since userspace will
see when that command is not supported.

> I do realize there's an API extensibility benefit to ignoring stuff you
> don't handle though (like 802.11 information element handling).  But if
> we're talking about an explicit request by a user for an option, if the
> driver doesn't support it, they should get an error.

Yeah, though the whole "stuff a bunch of options into SET_CONFIG" isn't
really where I'd like to be ideally, it's more that it is necessary to
be able to restart firmware less. Hence, I think set_config is not very
likely to be extended further, and new stuff gets new commands.

> That sounds like a good idea.  Putting 802.11d handling stuff into the
> kernel would essentially be duplicating the code and function of the
> userspace regulatory daemon, right?  That seems pointless.

Probably. But also see James's answers and the short thread resulting
from that.

> Another questions; I didn't see anything for encryption and auth and
> stuff yet.  Are you just trying to get the basics down before going on
> to that stuff? 

Yes, I'm not that far yet.

> What do you still have on your ToDo list for nl80211 before you'd
> consider "ready" to take over real configuration functions?

I don't really have an explicit ToDo list, but here are a few points
that come to mind
 * notification support when parameters change multicast a netlink
   message to all subscribers of that group
 * transmit status notification support for packet injection (sort of
   ties in with the first point)
 * scan results (also somewhat related to the first point)
 * crypto and auth support

> > +	/* unconditionally allow some common commands we handle centrally */
> > +	NLA_PUT_FLAG(msg, NL80211_CMD_GET_CMDLIST);
> > +	NLA_PUT_FLAG(msg, NL80211_CMD_GET_WIPHYS);
> > +	NLA_PUT_FLAG(msg, NL80211_CMD_GET_INTERFACES);
> > +
> > +	CHECK_CMD(list_interfaces, GET_INTERFACES);
> 
> Don't these two do exactly the same thing?  The first one adds
> GET_INTERFACES unconditionally, the next adds it (again!) if the
> interface supports it.  Either we add it unconditionally or we add it
> conditionally, but not both :)

Heh, yeah, it should be added unconditionally since it's one of the very
few calls that all operation structs must have assigned. Not that it
hurts to have it in there twice ;)

> I think we need a GET_SCAN here as well.  INITIATE_SCAN should
> definitely be CAP_NET_ADMIN-only or whatever, but GET_SCAN can be
> user-accessible.  Non-root stuff should still be able to get scan
> results even if they can't initiate one.

Yeah, we'll want that, but I haven't really thought about how we pass
scan results to userspace. We could be passing them out whenever we see
a change by way of some UPDATE_SCAN_RESULT command that is multicast to
all subscribers of a "scan results" group, for example.

> You also don't necessarily want to have to initiate a scan every time
> you want the results.  Drivers and/or d80211 should be caching the
> results anyway.  If d80211 is not, it should be.

Yeah. I think d80211 is caching but I don't really know.

>> "FLAG_SCAN_ACTIVELY"

> ACTIVELY is an adverb, and that doesn't parse very well in this context.

Heh

> It also just sounds weird here.  Better options:
> 
> FLAG_SCAN_ACTIVE
> FLAG_SCAN_TYPE_ACTIVE (<-- my favorite)
> FLAG_ACTIVE_SCAN

Yeah, I like TYPE_ACTIVE. Will change for the next posting.

Thanks for your comments, much appreciated.

johannes
