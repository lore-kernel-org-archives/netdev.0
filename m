From: Phil Sutter <phil@nwl.cc>
Subject: RFC: ss: improve horizontal output scaling
Date: Thu, 24 Sep 2015 13:16:50 +0200
Message-ID: <20150924111650.GY24212@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:52816 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752318AbbIXLQv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 07:16:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Currently, ss scales it's output to the available horizontal screen
space available, so that the regular columns (Netid, State, Recv-Q,
Send-Q, Local Address:Port and Peer Address:Port) use the maximum space
available and extended information (e.g. users) get wrapped into a new
line.

While this approach is sufficient for smaller terminals to improve
readability, it's kind of awkward in full-screen terminals which provide
enough space to display everything on the same line.

On the other hand, the current approach makes sense in that the output
width is hard to predict: Unix domain sockets have a filesystem path as
local address, which might be really long (e.g. 68 characters for a
libvirt socket on my box). The '-p' flag prints process names, so
extended information might become very long as well. The actual width of
each line's fields is not known before it has been printed. Since input
potentially comes from netlink, there is no random access which could be
used to scroll quickly through the input and find each column's longest
field.

There are a number of possible ways to improve this:

1. Introduce scalemax parameter:
   This parameter specifies the maximum terminal width to scale to.
   Implementation is trivial, and works well for me as my terminals are
   either 95, 126 or 193 characters wide. Setting scalemax to 128 leaves
   line wrapping in place in all but full-screen mode. Though other's
   mileage may vary, and fiddling with this number is inconvenient as
   well.

2. Implement wide output mode:
   Wide output mode would be what's currently being done. Not enabling
   it (via '-W' e.g.) would hard-limit columns to a given width,
   breaking down output if it exceeds that. E.g. instead of
   '/path/to/some_very_deep/file_name' print '/path/to...ile_name'. This
   makes column widths predictable and thereby allows to reliably decide
   whether output fits on the terminal or not.

Another, indirectly related issue I discovered while playing with the
above, is the fixed spacing between columns. Given an output like this:

| A   B   C
| ---------
| 1   2   3
| 4asdf   5   6
| 7   8   9

Could be improved to this:

| A   B   C
| ---------
| 1   2   3
| 4asdf 5 6
| 7   8   9

I would like to hear your opinions on whether there is demand for
improvements in this area in general, if any of the above approaches are
worth following (and potentially acceptable) or if there are better
ones.

Thanks, Phil
