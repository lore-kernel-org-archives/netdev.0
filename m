From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Move fib_alias out of fib_hash.c
Date: Wed, 29 Sep 2004 12:53:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929125359.12a00ba7.davem@davemloft.net>
References: <20040928214722.11aef8e0.davem@davemloft.net>
	<16730.53965.503605.943263@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, robert.olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16730.53965.503605.943263@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004 17:20:45 +0200
Robert Olsson <Robert.Olsson@data.slu.se> wrote:

>   we can interface new lookups cleanly. For a trie something like:

You are already making a critical logic error.

You cannot find the longest matching prefix and just use that.

Rather, you must iterate through all matching prefixes in the
table from longest to shortest, trying fib_semantic_match() on
each one until it says OK.

If you don't do that, then you're not providing the same behavior
of the current code.  If next hops go down, you have to try the
next longest matching prefix and so on and so forth.  It can also
be the case that the longest matching prefix entry has no matching
TOS key, whereas a shorter prefix does.

This makes using a new algorithm very non-trivial.

Probably what you should do is keep an array on the function
stack, recording shorter prefix entries you see on your walk
down to the longest matching prefix.  Then you process the array
one entry at a time back to the root, trying fib_semantic_match()
on each one.
