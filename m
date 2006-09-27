From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 08/23] e1000: add multicast stats counters
Date: Wed, 27 Sep 2006 13:09:16 -0700
Message-ID: <451ADA6C.10600@intel.com>
References: <F2C59D1E488E7A4FB7F6F673DAF8325901C7BBF3@orsmsx413.amr.corp.intel.com> <4511E119.3080302@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: cramerj <cramerj@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:54858 "EHLO mga03.intel.com")
	by vger.kernel.org with ESMTP id S1030745AbWI0ULB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 16:11:01 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4511E119.3080302@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> cramerj wrote:
>>> Williams, Mitch A wrote:
>>>>>> +    { "rx_broadcast", E1000_STAT(stats.bprc) }, +    {
>>>>>> "tx_broadcast", E1000_STAT(stats.bptc) }, +    { "rx_multicast",
>>>>>> E1000_STAT(stats.mprc) }, +    { "tx_multicast",
>>>>>> E1000_STAT(stats.mptc) }, { "rx_errors",
>>>>>> E1000_STAT(net_stats.rx_errors) }, { "tx_errors",
>>>>>> E1000_STAT(net_stats.tx_errors) }, { "tx_dropped",
>>>>>> E1000_STAT(net_stats.tx_dropped) },
>>>>> NAK -- you also need to remove the standard net stats, which are 
>>>>> exported elsewhere
>>>> Jeff, can you please explain the reason for this NAK a little more? 
>>>> Neither Auke nor I understand why you rejected the patch.
> 
>>>> This patch just adds the display of a few more stats in Ethtool.  It 
>>>> doesn't affect any other counters, and is really just a convenience 
>>>> feature.  I added this to the driver because of a customer request.
>>> Adding those stats is fine.  You guys just need to remove the existing 
>>> mess first.
> 
>> Since we have 1-to-1 mapping of some of our statistics registers to the 
>> net_stats, we could s/net_stats/stats/.  However, there are a few 
>> net_stats (e.g. net_stats.rx_errors) that encapsulate more than one e1000
>> statistic register of which we don't have a private stat member defined.
>> 
>> For those statistics, is it really necessary to add another stat structure
>> just to rm "net_stats" from that list we pass to ethtool?  At best, it
>> would look something like this...
>> 
>> { "foo_count", E1000_STAT(stats.foo) }, - { "rx_errors",
>> E1000_STAT(net_stats.rx_errors) }, + { "rx_errors",
>> E1000_STAT(eth_stats.rx_errors) }, { "bar_count", E1000_STAT(stats.bar) },
>> 
>> 
>> If so, well, OK.  I'm just scratching my head as to why it's a "mess" 
>> as-is.
> 
> The ethtool get-stats sub ioctl has _always_ been for exporting _only_ 
> NIC-private statistics.
> 
> So, no, there is no inherent connection between adding multicast stats and
> removing ones that should have never been in the list.  But if I don't put
> my foot down, this will never get corrected.

okay, here's my offer - we fix it as much as we can. I realize that it may not
be enough but I doubt that removeing stats makes people happy. I suggest that
we take one step in the right direction and another one later if we must.

this is in my queue.

Auke

---

e1000: add multicast stats counters

From: Mitch Williams <mitch.a.williams@intel.com>

Add 4 multicast and broadcast hardware counters (rx/tx), and eliminate
as many non-hardware counters as possible.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

  drivers/net/e1000/e1000_ethtool.c |   32 ++++++++++++++++++--------------
  drivers/net/e1000/e1000_hw.h      |    4 +++-
  drivers/net/e1000/e1000_main.c    |    9 ++++-----
  3 files changed, 25 insertions(+), 20 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c /drivers/net/e1000/e1000_ethtool.c
index 858c14d..9791b8a 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -56,26 +56,30 @@ struct e1000_stats {
  #define E1000_STAT(m) sizeof(((struct e1000_adapter *)0)->m), \
  		      offsetof(struct e1000_adapter, m)
  static const struct e1000_stats e1000_gstrings_stats[] = {
-	{ "rx_packets", E1000_STAT(net_stats.rx_packets) },
-	{ "tx_packets", E1000_STAT(net_stats.tx_packets) },
-	{ "rx_bytes", E1000_STAT(net_stats.rx_bytes) },
-	{ "tx_bytes", E1000_STAT(net_stats.tx_bytes) },
-	{ "rx_errors", E1000_STAT(net_stats.rx_errors) },
-	{ "tx_errors", E1000_STAT(net_stats.tx_errors) },
+	{ "rx_packets", E1000_STAT(stats.gprc) },
+	{ "tx_packets", E1000_STAT(stats.gptc) },
+	{ "rx_bytes", E1000_STAT(stats.gorcl) },
+	{ "tx_bytes", E1000_STAT(stats.gotcl) },
+	{ "rx_broadcast", E1000_STAT(stats.bprc) },
+	{ "tx_broadcast", E1000_STAT(stats.bptc) },
+	{ "rx_multicast", E1000_STAT(stats.mprc) },
+	{ "tx_multicast", E1000_STAT(stats.mptc) },
+	{ "rx_errors", E1000_STAT(stats.rxerrc) },
+	{ "tx_errors", E1000_STAT(stats.txerrc) },
  	{ "tx_dropped", E1000_STAT(net_stats.tx_dropped) },
-	{ "multicast", E1000_STAT(net_stats.multicast) },
-	{ "collisions", E1000_STAT(net_stats.collisions) },
-	{ "rx_length_errors", E1000_STAT(net_stats.rx_length_errors) },
+	{ "multicast", E1000_STAT(stats.mprc) },
+	{ "collisions", E1000_STAT(stats.colc) },
+	{ "rx_length_errors", E1000_STAT(stats.rlerrc) },
  	{ "rx_over_errors", E1000_STAT(net_stats.rx_over_errors) },
-	{ "rx_crc_errors", E1000_STAT(net_stats.rx_crc_errors) },
+	{ "rx_crc_errors", E1000_STAT(stats.crcerrs) },
  	{ "rx_frame_errors", E1000_STAT(net_stats.rx_frame_errors) },
  	{ "rx_no_buffer_count", E1000_STAT(stats.rnbc) },
-	{ "rx_missed_errors", E1000_STAT(net_stats.rx_missed_errors) },
-	{ "tx_aborted_errors", E1000_STAT(net_stats.tx_aborted_errors) },
-	{ "tx_carrier_errors", E1000_STAT(net_stats.tx_carrier_errors) },
+	{ "rx_missed_errors", E1000_STAT(stats.mpc) },
+	{ "tx_aborted_errors", E1000_STAT(stats.ecol) },
+	{ "tx_carrier_errors", E1000_STAT(stats.tncrs) },
  	{ "tx_fifo_errors", E1000_STAT(net_stats.tx_fifo_errors) },
  	{ "tx_heartbeat_errors", E1000_STAT(net_stats.tx_heartbeat_errors) },
-	{ "tx_window_errors", E1000_STAT(net_stats.tx_window_errors) },
+	{ "tx_window_errors", E1000_STAT(stats.latecol) },
  	{ "tx_abort_late_coll", E1000_STAT(stats.latecol) },
  	{ "tx_deferred_ok", E1000_STAT(stats.dc) },
  	{ "tx_single_coll_ok", E1000_STAT(stats.scc) },
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 47f34f2..113344e 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -1298,6 +1298,7 @@ struct e1000_hw_stats {
      uint64_t algnerrc;
      uint64_t symerrs;
      uint64_t rxerrc;
+    uint64_t txerrc;
      uint64_t mpc;
      uint64_t scc;
      uint64_t ecol;
@@ -1330,8 +1331,9 @@ struct e1000_hw_stats {
      uint64_t gotch;
      uint64_t rnbc;
      uint64_t ruc;
-    uint64_t rfc;
      uint64_t roc;
+    uint64_t rlerrc;
+    uint64_t rfc;
      uint64_t rjc;
      uint64_t mgprc;
      uint64_t mgpdc;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 447b7c8..5296a82 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3338,16 +3338,15 @@ #define PHY_IDLE_ERROR_COUNT_MASK 0x00FF
  		adapter->stats.crcerrs + adapter->stats.algnerrc +
  		adapter->stats.ruc + adapter->stats.roc +
  		adapter->stats.cexterr;
-	adapter->net_stats.rx_length_errors = adapter->stats.ruc +
-	                                      adapter->stats.roc;
+	adapter->stats.rlerrc = adapter->stats.ruc + adapter->stats.roc;
+	adapter->net_stats.rx_length_errors = adapter->stats.rlerrc;
  	adapter->net_stats.rx_crc_errors = adapter->stats.crcerrs;
  	adapter->net_stats.rx_frame_errors = adapter->stats.algnerrc;
  	adapter->net_stats.rx_missed_errors = adapter->stats.mpc;

  	/* Tx Errors */
-
-	adapter->net_stats.tx_errors = adapter->stats.ecol +
-	                               adapter->stats.latecol;
+	adapter->stats.txerrc = adapter->stats.ecol + adapter->stats.latecol;
+	adapter->net_stats.tx_errors = adapter->stats.txerrc;
  	adapter->net_stats.tx_aborted_errors = adapter->stats.ecol;
  	adapter->net_stats.tx_window_errors = adapter->stats.latecol;
  	
