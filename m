From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH 0/6] use sctp 1-to-1 API
Date: Tue, 11 Aug 2015 19:22:19 -0300
Message-ID: <cover.1439328440.git.marcelo.leitner@gmail.com>
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Teigland <teigland@redhat.com>, tan.hu@zte.com.cn
To: cluster-devel@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38688 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932675AbbHKWWj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Aug 2015 18:22:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc'ing netdev and sctp maintainers so we keep everyone in the loop.
This series will be handled via dlm tree now.

Currently, loading dlm module will require loading sctp module too and
this is not wanted. This link is caused only by the usage of
sctp_do_peeloff(), and just it.

Previously this operation was performed through getsockopt() but it
caused a file descriptor to be allocated, as it was initially intended
only for userspace, and this caused serious issues. Please see
2f2d76cc3e93 ("dlm: Do not allocate a fd for peeloff") for more info on
that issue.

Previous attempts on breaking such link by either creating a new
getsockopt() option or by changing the current one were rejected on
netdev, as both were deemed unpractical.

So, as Vlad Yasevich noticed, DLM has no bigger reason to use that call.
Thus we can avoid using it by switching to 1-to-1 (TCP style) API.

Such move also simplificates how DLM deals with SCTP sockets because now
it can deal with them almost like TCP ones. I.e., there is no need to
handle SCTP events and error recovery is simplified in some places.

While switching to 1-to-1 API a couple of issues were noticed on DLM.
They are fixed in the first patches of this series and are the minimum
requirements to have both implementations compatible. That said, usage
of mixed versions without them will cause instability.

Tested with test applications kindly provided by David Teigland, on a
two node cluster, with TCP and SCTP with 1 and 2 addresses each.

Many thanks,

Marcelo Ricardo Leitner (6):
  dlm: fix connection stealing if using SCTP
  dlm: fix race while closing connections
  dlm: fix not reconnecting on connecting error handling
  dlm: use sctp 1-to-1 API
  dlm: replace BUG_ON with a less severe handling
  dlm: fix reconnecting but not sending data

 fs/dlm/lowcomms.c | 704 ++++++++++++++++++++----------------------------------
 1 file changed, 261 insertions(+), 443 deletions(-)

-- 
2.4.3
