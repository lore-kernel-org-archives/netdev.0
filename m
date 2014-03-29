From: Dave Jones <davej@redhat.com>
Subject: new leaks in bridging code.
Date: Sat, 29 Mar 2014 17:01:02 -0400
Message-ID: <20140329210102.GA22516@redhat.com>
References: <533730f2396e8_1c4bb46874192e@209.249.196.67.mail>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: makita.toshiaki@lab.ntt.co.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62549 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751999AbaC2VBd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Mar 2014 17:01:33 -0400
Content-Disposition: inline
In-Reply-To: <533730f2396e8_1c4bb46874192e@209.249.196.67.mail>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

yesterdays bridging changes introduced leaks in the exit paths..

** CID 1194948:  Resource leak  (RESOURCE_LEAK)
/net/bridge/br_vlan.c: 196 in br_allowed_ingress()
/net/bridge/br_vlan.c: 218 in br_allowed_ingress()
/net/bridge/br_vlan.c: 220 in br_allowed_ingress()

*** CID 1194948:  Resource leak  (RESOURCE_LEAK)
/net/bridge/br_vlan.c: 196 in br_allowed_ingress()
190     
191     		/* Frame had a tag with VID 0 or did not have a tag.
192     		 * See if pvid is set on this port.  That tells us which
193     		 * vlan untagged or priority-tagged traffic belongs to.
194     		 */
195     		if (pvid == VLAN_N_VID)
>>>     CID 1194948:  Resource leak  (RESOURCE_LEAK)
>>>     Returning without freeing "skb" leaks the storage that it points to.
196     			return false;
197     
198     		/* PVID is set on this port.  Any untagged or priority-tagged
199     		 * ingress frame is considered to belong to this vlan.
200     		 */
201     		*vid = pvid;
/net/bridge/br_vlan.c: 218 in br_allowed_ingress()
212     
213     		return true;
214     	}
215     
216     	/* Frame had a valid vlan tag.  See if vlan is allowed */
217     	if (test_bit(*vid, v->vlan_bitmap))
>>>     CID 1194948:  Resource leak  (RESOURCE_LEAK)
>>>     Returning without freeing "skb" leaks the storage that it points to.
218     		return true;
219     
220     	return false;
221     }
222     
223     /* Called under RCU. */
/net/bridge/br_vlan.c: 220 in br_allowed_ingress()
214     	}
215     
216     	/* Frame had a valid vlan tag.  See if vlan is allowed */
217     	if (test_bit(*vid, v->vlan_bitmap))
218     		return true;
219     
>>>     CID 1194948:  Resource leak  (RESOURCE_LEAK)
>>>     Returning without freeing "skb" leaks the storage that it points to.
220     	return false;
221     }
222     
223     /* Called under RCU. */
224     bool br_allowed_egress(struct net_bridge *br,
225     		       const struct net_port_vlans *v,
