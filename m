From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] textsearch infrastructure + skb_find_text()
Date: Thu, 05 May 2005 08:42:17 -0400
Message-ID: <1115296937.7680.52.camel@localhost.localdomain>
References: <20050504234036.GH18452@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Pablo Neira <pablo@eurodev.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050504234036.GH18452@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-05-05 at 01:40 +0200, Thomas Graf wrote:
> The patch below is a report on the current state of the textsearch
> infrastructure and its first user skb_find_text(). The textsearch
> is kept as simple as possible but advanced enough to handle non-linear
> data such as skb fragments. Unlike in many other approaches the text
> input is not seen as a single pointer but rather as a continuously
> called callback get_text() until 0 is returned allowing to search
> on any kind of data and to implement customized from-to limits.
> 

How is this different from libqsearch? IIRC, it also kept pointers and
callbacks.

BTW, I hope theres sync with libqsearch - at least some canibalization
of ideas.
Also hopefully, pluggin of ne algorithms is trivial (e.g boyer-moore
could be included in addition to kmp etc)

> The patch is separated into 3 parts, the first one being the textsearch
> infrastructure itself followed by a simple Knuth-Morris-Pratt
> implementation for reference. I'm also working on what could be called
> the smallest regular expression implementation ever but I left that
> out for now since it still has issues. Last but not least the
> function skb_find_text() written in a hurry and probably not yet
> correct but you should get the idea. From a userspace perspective
> the first user will be an ematch but writing it will be peanuts
> so I left it out for now.
> 

nice

> Basically what it looks like right now is:
> 
> int pos;
> struct ts_state;
> struct ts_config *conf = textsearch_prepare("kmp", "hanky", 5, GFP_KERNEL, 1);
>
> /* search for "hanky" at offset 20 until end of packet */
> for (pos = skb_find_text(skb, 20, INT_MAX, conf, &state;
>      pos >= 0;
>      pos = textsearch_next(conf, &state)) {
>         printk("Need a hanky? I found one at offset %d.\n", pos);
> }
> 

I have a lot of questions:
- does a string have to be terminated by \0?
- do you keep state of the string from the begining? ex: how do you know
that preceeding "hanky" was "Need a"?
- all sorts of limits: how long is the string? etc
- what happens if a string spans multiple skbs or even multiple
fragments?

> textsearch_put(conf);
> kfree(conf);
> 
> You might wonder about the 1 given to _prepare(),  it indicates whether
> to autoload modules because the ematches will need it to be able to drop
> rtnl sem.
> 

do you really wanna leave that decision upto the user?

> The code is not tested and cerainly not bug free yet but should compile.
> 
> Thoughts?

I dont have time to look at the patch to sufficiently critique it, but
it looks like a good start - maybe this weekend.
It would be nice to have other utilities which could be loaded eg; case
compare, regualr expressions, strchr after you match, etc
Of course all this to be followed by actions such as strok etc.
Probably all this is a layer above this - but essentially when you are
doing this keep the desire to do this in mind.

cheers,
jamal
