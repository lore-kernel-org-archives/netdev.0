From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] cfg80211 and nl80211
Date: Fri, 06 Oct 2006 11:41:34 +0200
Message-ID: <1160127694.2715.51.camel@ux156>
References: <1159435399.2648.17.camel@ux156>
	 <1159805711.2834.67.camel@localhost.localdomain>
	 <1159947674.2817.19.camel@ux156> <1159971561.2817.87.camel@ux156>
	 <1159984658.3287.98.camel@localhost.localdomain>
	 <20061005162006.GC17517@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>, netdev <netdev@vger.kernel.org>,
	Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:64491 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751391AbWJFJkw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Oct 2006 05:40:52 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20061005162006.GC17517@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Let me try to summarise this... probably wrong :)

> 1.5 KB sounds like a small scan result set to me.. I'm hitting 100+
> BSSes at work (well, not really your normal environment ;-), and 50 at
> home.. These go way beyond 1.5 KB; closer to 32 KB at times, I'd guess.

Ok this is easy, we need huge results and thus can't reasonably push
them out on each change... Maybe some sequence number thingie could be
used? I'd like to have a .dumpit call with genl to actually dump all the
scan results to userspace, maybe that message could be multicast to
interested stations if someone requests one? No idea... Thomas?

As for the auth/crypto/key mgmt issue... It looks like these three are
basically orthogonal. If I understand correctly, you need to be able to
 * set a key including algorithm for the possible
     - key indexes 0,1,2,3
     - a STA identified by MAC address
     (and the key is identified by these uniquely)
   This includes
     - algorithm (none to clear, wep, tkip, ccmp, ...)
     - key material
     - TSC/SN (only valid for some algorithms)
     (key material length is used to decide between wep types, and some
     attributes may be left off, e.g. to change the tsc/sn without
     changing the key material or algorithm)
 * set transmit key index (STA only?)
 * set multicast/broadcast key index
 * dot11ExcludeUnecrypted (default true)
 * authentication mode, including
     - allowed algorithms (open, shared-key, ...)
     - key index of key to use
     - preference of use? That would make the allowed algorithms a list
       instead of a bitfield
 * set IE(s) (only some cards)
 * set allowed cipher suites for RSN/WPA IE generation (only some cards)
   [do we need to be able to distinguish between these or is it fine to
   just try both and get an error for one?]
 * a way to get the device's capabilities (per-net_device)
    - crypto algorithms
    - auth algorithms
    - ...?

Does that sound right? (throw in get versions for most of these, of
course)

Open issues:
 * associating a key index with a mac address for unicast wep key?

Hmm. That's at least 8 operations that WE sticks into 3. No wonder no
one understands it...

johannes
