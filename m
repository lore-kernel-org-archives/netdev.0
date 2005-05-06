From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] textsearch infrastructure + skb_find_text()
Date: Fri, 6 May 2005 16:43:08 +0200
Message-ID: <20050506144308.GF28419@postel.suug.ch>
References: <20050504234036.GH18452@postel.suug.ch> <427A51A2.8090600@eurodev.net> <20050505174224.GB25977@postel.suug.ch> <427AC96E.2020208@eurodev.net> <20050506123639.GE28419@postel.suug.ch> <1115384649.7660.140.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira <pablo@eurodev.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1115384649.7660.140.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1115384649.7660.140.camel@localhost.localdomain> 2005-05-06 09:04
> I dont see any difference between the two in terms of state storage.
> Can you really avoid storing state? Can you give an example?

The state is kept on the stack since there is only one call to
the algorithm's search function per match iteration. Look at
the code below, it is called once and fetches the data
continuously until EOF or a match has been found.

get_text() sets *text to the start of the next buffer at the
virtual absolute position `consumed' and returns the length
of the new buffer.

	int i, q = 0, consumed = state->offset;

	for (;;) {
		text_len = conf->get_text(consumed, &text, conf, state);

		if (text_len == 0)
			break; /* no match found */

		for (i = 0; i < text_len; i++) {
			while (q > 0 && pattern[q] != text[i])
				q = prefix_tbl[q - 1];
			if (pattern[q] == text[i])
				q++;
			if (q == pattern_len) {
				state->offset = consumed + i - pattern_len + 1;
				return state->offset;
			}
		}

		consumed += text_len;
	}

A very simple implementation of get_text() could look like this:

static inline int get_linear_text(int offset, unsigned char **text,
				  struct ts_config *conf,
				  struct ts_state *state)
{
	unsigned char *string = (unsigned char *) state->args[0];
	size_t len = state->args[1];

	if (offset < len) {
		*text = string + offset;
		return len - offset;
	} else
		return 0;
}

As you can see, it expects a char * in args[0] and the length of it
in args[1]. All it does is check whether all bytes have been read
already and if not return the remaining part of the buffer so even
if the search algorithm can't consume all the bytes returned it will
still work as expected.

> The other scheme is to have the callback return a code which says
> "get me more text" or " enough/done" in which case the state machine for
> the search alg is no different in both cases.

In the case of interruptable search algorithms, we have to make sure to
save enough state information to continue at the same position. Surely
this is no problem with KMP or BM but gets real complex in the case
of automata based searching algorithms such as regular expressions. It
would mean to have a set of conditional jumps into the algorithms, I
tried it and it really gets complex.

Example: Assume we are are processing a regular expression with automata
approach and are currently look at a 'ANY' (+) recurrence. First thing
we do is check if there are more torkens to parse, if not we can return
true immediately. Otherwise we have to do a look ahead on the pattern
and cycle through the text looking if we can find the token following
the 'ANY' recurrence, e.g.

pattern := "c*\d+A"
current-token := \d+
next-token := 'A'
text := "ccc123A"
current-character := text[3] ('1')

  while NOT next-token matches current-character do
    if current-token matches current-character then
      goto no-match
    endif
    current-character := next(text)
    proceed-to-next-character()
    /* At this position we'd have to return, fetch new text and come back
       right here with the exact same state, difficult huh? */
    if NOT more text to process then
      goto no-match 
    endif
  endwhile

Not sure if this is clear out of context but maybe it gives you an idea
why it is easier to maintain state of get_text() rather than the state
of a whole searching algorithm.

> It depends on the search algorithm - if it is small, you benefit from
> either scheme. If it is large, you loose in both.

That's true, smallish algorithms such as KMP and BM don't gain much
but for complex algorithms such as regexp my approach really is a
lot faster.

> > and
> > b) it allows the searching algorithm to do prefetching.
> > 
> 
> I am trying to sink this in; prefetching would be valuable for regexp,
> but why would the other scheme not be able to do it? 

I'm really not an expert on the validity of L1 caches and how to optimize
it best but I believe that the less memory movement is in between the
more likely prefetching helps? Both schemes involve a switch to another
stack namespace but get_text() tends to be a lot smaller and less intrusive
than a store & reload of a complex state machine. I really can't tell
which is better regarding this subject without trying it out actually.
