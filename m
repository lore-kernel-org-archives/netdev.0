From: Santwona.Behera@Sun.COM
Subject: Interface proposal for rx classification using ethtool
Date: Mon, 29 Sep 2008 10:28:07 -0700
Message-ID: <48E11027.3060400@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: Matheos Worku <Matheos.Worku@Sun.COM>,
	Santwona Behera <Santwona.Behera@Sun.COM>
To: netdev@vger.kernel.org, gkernel-commit@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:37076 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300AbYI2R2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 13:28:21 -0400
Received: from fe-sfbay-10.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m8THSArs022275
	for <netdev@vger.kernel.org>; Mon, 29 Sep 2008 10:28:21 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-10.sun.com by fe-sfbay-10.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0K7Y00M01WBX4400@fe-sfbay-10.sun.com>
 (original mail from Santwona.Behera@Sun.COM) for netdev@vger.kernel.org; Mon,
 29 Sep 2008 10:28:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is the proposed design for implementing an interface to add, delete 
and
manage rules for RX packet classification on ethertool with niu as the 
first
target hardware. This is the second installment of network flow 
classification
support (the first one was for rx flow distribution based on hashing 
that was
added in June). Please review and send your feedback.

1. The ethertool application will have an interface to add a 
classification rule
and the target RX ring for packets that match the rule. The rules are added
on a per port basis. Each new rule that is added is represented by a 
unique ID.
This ID can be used by the user to delete the rule or query the details 
of the
rule (both interfaces provided via ethertool).

2. Here is the list of cmds/interfaces that will be added to ethertool (as
suboptions in the rx_classification option) to achieve this:

   - get the number of RX rings available to this port.
   - add a rule (flow-tuple/mask to RX ring mapping)
   - delete a rule
   - query a particular rule or all rules for this port

3. Within ethertool, there will be a manager for these rules that will 
order
the rules on a per port basis according to the policy chosen by the 
user. In
the first cut, the policy will be hardcoded as longest prefix first 
ordering.
Before adding any rules to the hardware, the rule manager will first query
the hardware for the ordering that it implements for matching, e.g., 
low-to-high
(as in case of niu TCAM). This information will be taken into account while
writing to the rule-manager and to the hardware.

4. In the niu driver, there will be a local array of the tcam_entries (for
supporting queries from ethertool).

5. There is no protection against inconsistencies between the tcam entries
and the user view of it that can arise if multiple instances of ethertool
happen to write the same rule (tcam_entry).

thanks,
--santwona
