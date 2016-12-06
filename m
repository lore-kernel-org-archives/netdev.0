From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [PATCH RFC v1 0/2] ethtool: add support for VF in ring_cookie
Date: Tue,  6 Dec 2016 04:40:29 -0800
Message-ID: <20161206124031.32346-1-jacob.e.keller@intel.com>
Cc: netdev@vger.kernel.org, Jacob Keller <jacob.e.keller@intel.com>
To: "John W . Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:18386 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753019AbcLFMke (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 07:40:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ring_cookie value for an ntuple filter is used by the driver to
determine what queue to direct the traffic towards. Since the main
function has cnotrol over all queues it is possible to use this to
direct traffic to a queue on a virtual function rather than a queue on
the physical function. However, this was cumbersome to do if you did not
know exactly how the device laid out virtual function queues.

To alleviate this, the kernel side of the ethtool API gained a couple of
functions used to partition the ring_cookie value into a queue index,
and a virtual function index. It was assumed that no device was likely
to have more than 2^32 queues, and currently no device has more than 2^8
virtual functions, so the split was chosen such that the lower 32 bits
of the ring_cookie represent the queue, and the next 8 bits would
represent a virtual function id.

This is useful, but lacked support on the ethtool command line side. It
is possible to simply use hex notation, and to "know" that the driver
works in this manner. However, this makes use of and knowledge of the
feature not widespread.

This series attempts to fix that with two patches. First, we make use of
the access functions when displaying the queue. Since no device
currently supports queues beyond 2^32 it is unlikely that any driver
which does not honor this partitioning of the ring_cookie would have its
index incorrectly interpreted. This makes it so that the user will see
the queue index and virtual function index split apart instead of being
displayed as a combined base-10 number.

Additionally, the second patch adds support for a new notation for the
action. Instead of just using a number, we add support for the special
syntax "X/Y" where X would be a number from 0-256 which is the virtual
function index, while Y would be a number from 0 to 2^32 which is the
queue index. This makes it much easier to write the encoded ring_cookie
value.

This series is sent as an RFC so that others may comment on the design
of the new syntax, and offer alternative suggestions. Some of the ones I
have considered:

a) just leave the second part alone, and display the VF+queue split, but
do not provide an easier syntax for writing the split value. This is
easy to do, but leaves the feature as a sort of hidden gem.
Additionally, the user would most easily do this by writing it as hex
notation such as

  action 0x100000005

However, this is cumbersome. It can be partially alleviated by using
shell scripting on top of ethtool, but again is somewhat of a pain.

b) actually adding a new key work so that you would do something like
"queue x" and "vf y" or similar. However, this is much more difficult to
correctly implement. The current implementation of handling the values
assumes that each type argument is followed by a single argument which
fits into a well defined section of the structure. Because the structure
is not specified as le64 or be64, we can't use a union or similar to
make it correct (since placement in the union ordering would depend on
byte ordering of the field!) so we would have to re-architect the
handling of values to allow multiple keywords to combine into a single
value. This seemed incredibly cumbersome.

The disadvantage of the new syntax is that it *is* new syntax that we
have to parse ourselves, and that may not be obvious to users. However,
we can document it, and the current syntax will work for all drivers,
and the new syntax will generally only work on drivers which use the
ring_cookie partitioning in this manner (as no current driver has queues
beyond 2^32, as was decided when the partitioning scheme was added to
the ethtool header file).

I like the use of / but am open to alternative suggestions for a simple
sequence. Note that we cannot use spaces, as this would move into the
argv solution of (b) which I do not have time to implement, and would be
a much more massive project.

Jacob Keller (2):
  rxclass: use ethtool_get_flow_spec_ring to display queue and VF
  ethtool: add support to specify ring_cookie as VF/queue

 ethtool.8.in |  3 ++-
 rxclass.c    | 74 +++++++++++++++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 65 insertions(+), 12 deletions(-)

-- 
2.11.0.rc2.152.g4d04e67
