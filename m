From: Johannes Berg <johannes@sipsolutions.net>
Subject: d80211 and sta_aid for AP functionality
Date: Mon, 14 Aug 2006 10:19:24 +0200
Message-ID: <44E0320C.6090003@sipsolutions.net>
References: <44E02F41.2060300@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:14981 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751933AbWHNIT3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 04:19:29 -0400
To: Jouni Malinen <jkm@devicescape.com>, Jiri Benc <jbenc@suse.cz>
In-Reply-To: <44E02F41.2060300@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey,

I was looking through the d80211 code and noticed this comment and code:

        /* TODO: sta_aid could be replaced by 2008-bit large bitfield of
         * that could be used in TIM element generation. This would also
         * make TIM element generation a bit faster. */
        /* AID mapping to station data. NULL, if AID is free. AID is in the
         * range 1..2007 and sta_aid[i] corresponds to AID i+1. */
        struct sta_info *sta_aid[MAX_AID_TABLE_SIZE];

Note that this is part of struct ieee80211_if_ap which is in a union for 
each virtual device.

About 15 seconds later it almost blew me off my chair ;) I had realized 
that this is 8k kernel memory for each virtual device with absolutely no 
function in the common case! AX_AID_TABLE_SIZE is set to 2007 (the 
802.11 spec maximum)...

In fact, with this, the struct ieee80211_sub_if_data is 8560 bytes, 
without it it's a meager 588 bytes. Hence, when the interface is 
anything but an AP interface, we waste almost 8K. And even if it's an AP 
interface, who ever has 2007 stations associated?

Since the stations are saved in a hash-table (the hashing by the last 
byte of the mac address doesn't seem too efficient though...) all the 
sta_aids array needs to do is answer the following questions quickly:
 (a) is the AID N used?
 (b) what is the sta_info pointer for AID N?

Since userspace manages AIDs, we don't even need to be able to answer 
things like "what is the lowest unused AID?". I don't quite understand 
why we don't stop userspace from using the same AID for different 
stations, which will give surely result in trouble, but hey.

Looking through the code, I notice that above (a) and (b) can be 
collapsed into just keeping track of the TIM throughout the code. I 
suppose that's meant by the comment above? Then we can't add the check 
for saying 'hey you stupid userspace that AID is already used' but 
that's ok I guess.

If you can confirm that my analysis is correct I'd be willing to try 
making this change. This would at least go down to 251 bytes for the 
bitmap and thus reduce sub_if_data to about 760 bytes. The only 
complication I see with this right now is that of locking, but I haven't 
looked closely yet.

johannes

