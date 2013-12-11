From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [cfg80211 / iwlwifi] setting wireless regulatory domain doesn't work.
Date: Wed, 11 Dec 2013 16:17:10 +0100
Message-ID: <1819533168.20131211161710@eikelenboom.it>
References: <1507831110.20131018194349@eikelenboom.it> <792757788.20131023142849@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@frijolero.org>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	<linux-kernel@vger.kernel.org>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: "Berg, Johannes" <johannes.berg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <792757788.20131023142849@eikelenboom.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since i haven't got a response to this yet and after having the troubled machine back:
The problem is still present in linux 3.13-rc3

The problem seems to be in this piece of code:

root@creabox:/usr/src/linux-tip# git blame  -L 1567,1601 net/wireless/reg.c
fe33eb39 (Luis R. Rodriguez 2009-02-21 00:04:30 -0500 1567)
b2e253cf (Luis R. Rodriguez 2010-11-17 21:46:09 -0800 1568) /*
b2e253cf (Luis R. Rodriguez 2010-11-17 21:46:09 -0800 1569)  * Processes regulatory hints, this is all the NL80211_REGDOM_SET_BY_*
b2e253cf (Luis R. Rodriguez 2010-11-17 21:46:09 -0800 1570)  * Regulatory hints come on a first come first serve basis and we
b2e253cf (Luis R. Rodriguez 2010-11-17 21:46:09 -0800 1571)  * must process each one atomically.
b2e253cf (Luis R. Rodriguez 2010-11-17 21:46:09 -0800 1572)  */
fe33eb39 (Luis R. Rodriguez 2009-02-21 00:04:30 -0500 1573) static void reg_process_pending_hints(void)
b0e2880b (Luis R. Rodriguez 2010-11-17 21:46:08 -0800 1574) {
c492db37 (Johannes Berg     2012-12-06 16:29:25 +0100 1575)     struct regulatory_request *reg_request, *lr;
fe33eb39 (Luis R. Rodriguez 2009-02-21 00:04:30 -0500 1576)
c492db37 (Johannes Berg     2012-12-06 16:29:25 +0100 1577)     lr = get_last_request();
b0e2880b (Luis R. Rodriguez 2010-11-17 21:46:08 -0800 1578)
b2e253cf (Luis R. Rodriguez 2010-11-17 21:46:09 -0800 1579)     /* When last_request->processed becomes true this will be rescheduled */
c492db37 (Johannes Berg     2012-12-06 16:29:25 +0100 1580)     if (lr && !lr->processed) {
1a919318 (Johannes Berg     2012-12-03 17:21:11 +0100 1581)             REG_DBG_PRINT("Pending regulatory request, waiting for it to be processed...\n");
5fe231e8 (Johannes Berg     2013-05-08 21:45:15 +0200 1582)             return;

If i "comment out" the return above, setting the regulatory domain with "iw reg set XX" does work.

b2e253cf (Luis R. Rodriguez 2010-11-17 21:46:09 -0800 1583)     }
b2e253cf (Luis R. Rodriguez 2010-11-17 21:46:09 -0800 1584)
fe33eb39 (Luis R. Rodriguez 2009-02-21 00:04:30 -0500 1585)     spin_lock(&reg_requests_lock);
fe33eb39 (Luis R. Rodriguez 2009-02-21 00:04:30 -0500 1586)
b2e253cf (Luis R. Rodriguez 2010-11-17 21:46:09 -0800 1587)     if (list_empty(&reg_requests_list)) {
d951c1dd (Luis R. Rodriguez 2009-02-21 00:24:15 -0500 1588)             spin_unlock(&reg_requests_lock);
5fe231e8 (Johannes Berg     2013-05-08 21:45:15 +0200 1589)             return;
fe33eb39 (Luis R. Rodriguez 2009-02-21 00:04:30 -0500 1590)     }
b2e253cf (Luis R. Rodriguez 2010-11-17 21:46:09 -0800 1591)
b2e253cf (Luis R. Rodriguez 2010-11-17 21:46:09 -0800 1592)     reg_request = list_first_entry(&reg_requests_list,
b2e253cf (Luis R. Rodriguez 2010-11-17 21:46:09 -0800 1593)                                    struct regulatory_request,
b2e253cf (Luis R. Rodriguez 2010-11-17 21:46:09 -0800 1594)                                    list);
b2e253cf (Luis R. Rodriguez 2010-11-17 21:46:09 -0800 1595)     list_del_init(&reg_request->list);
b2e253cf (Luis R. Rodriguez 2010-11-17 21:46:09 -0800 1596)
fe33eb39 (Luis R. Rodriguez 2009-02-21 00:04:30 -0500 1597)     spin_unlock(&reg_requests_lock);
b0e2880b (Luis R. Rodriguez 2010-11-17 21:46:08 -0800 1598)
8848bef0 (Luis R. Rodriguez 2011-12-20 12:23:36 -0800 1599)     reg_process_hint(reg_request, reg_request->initiator);
fe33eb39 (Luis R. Rodriguez 2009-02-21 00:04:30 -0500 1600) }
fe33eb39 (Luis R. Rodriguez 2009-02-21 00:04:30 -0500 1601)

--
Sander


Wednesday, October 23, 2013, 2:28:49 PM, you wrote:

> Ping ?

> Friday, October 18, 2013, 7:43:49 PM, you wrote:

>> Hi,

>> I'm trying to change the regulatory domain for my wireless adapter:
>> Intel Corporation Centrino Advanced-N 6235

>> But it fails to change from "world" to anything else (say "US")

>> I enabled debug options used iwlwifi.debug=0x00043FFF for boot and added some printk's which i think should be triggered .. but they are not.
>> It seems in function "reg_process_pending_hints" the processing is deferred,
>> but from the code i don't see how it would ever be triggered to complete ?

>> Hope some can give some hints to what could be going on ...

>> Attached:
>> - full syslog from boot till "iw set reg US", which is done at "Oct 18 21:26:09"
>> - patch.diff with the added debug printk's against 3.12-rc5 (it also contains the patch that was needed to suppress another warning in the iwlwifi driver.

>> --
>> Sander
