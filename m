From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC] textsearch infrastructure et al v2
Date: Sat, 28 May 2005 00:47:25 +0200
Message-ID: <20050527224725.GG15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave, I'm going through another RFC round to hopefully get
some comments on the notes below.

I'm not yet satistifed with the core infrastructure wrt to
non-linear data, especially for complex cases such as non
linear skbs. The current way can be easly described as:

search_occurrance()
  search-algorithm()
    while get-next-segment()
      process-segment()

So basically we save the state of the segment fetching
instead of saving the state of the search algorithm which
would be way too complex for things like regular expression
string matching.

In the case of non linear skbs this would lead to:

1) start of search algorithm
2) first call to get_text(), return skb->data
3) processing of the text segment, return if match found
4) second call to get_text(), map and return first fragment
5) processing ...
6) third call to get_text(), unmap first fragment, map and
   return second fragment
7) processing ...
n) etc.

Assuming that the most common case is to have no fragments
at all or if we only process a very limited number of
fragments (due to restricted search area) this should be
quite fast. However, the complexity of get_text() for the
skb case including the map/unmap of the fragment interrupts
the search flow quite a bit which hurts performance.

In order to address this issue I'm having second thoughts
about whether to allow the textsearch user to provide an
array of text segments including their size, i.e. the skb
fragments could be maped in prior and the algorithm could
scan through it like nothing. ;-> However, this has one
essential drawback, we might map fragments which we'll
never use so this can be slower in the end.

Any other ideas around?
