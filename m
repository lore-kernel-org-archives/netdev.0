From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 1/4][MAC80211]: Fix GFP_KERNEL allocation under read lock.
Date: Tue, 06 May 2008 21:46:38 +0400
Message-ID: <4820997E.1070305@openvz.org>
References: <48206F4C.5050105@openvz.org> <200805061840.37713.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>,
	linux-wireless@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ingo Oeser <netdev@axxeo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:46064 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755943AbYEFRuM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 13:50:12 -0400
In-Reply-To: <200805061840.37713.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Oeser wrote:
> Hi Pavel,
> 
> regarding:
> 
> [PATCH 1/4][MAC80211]: Fix GFP_KERNEL allocation under read lock
> [PATCH 2/4][MAC80211]: Fix not checked kmalloc() result
> 
> Pavel Emelyanov schrieb:
>> The mesh_path_add() read-locks the pathtbl_resize_lock and calls
>> kmalloc with GFP_KERNEL mask.
>>
>> Fix it and move the endadd2 label lower. It should be _before_ the
>> if() beyond, but it makes no sense for it being there, so I move it
>> right after this if().
> 
> What about doing both allocations in succession to local variables,
> share the failure path if an error occours an kfree them unconditionally 
> like this?

I do not quite like doing so. Since this relies on fact that kfree bears
NULL pointers. But if we ever switch from kmalloc to kmem_cache_alloc,
this will result in an oops.

And as far as sharing the error paths are concerned, I make such thing
in the 4th patch in a more classical manner.

> new_node = kmalloc(sizeof(struct mpath_node), GFP_KERNEL);
> new_mpath = kzalloc(sizeof(struct mesh_path), GFP_KERNEL);
> if (!new_node || !new_mpath) {
> 	kfree(new_mpath);
> 	kfree(new_node);
> 	atomic_dec(&sdata->u.sta.mpaths);
> 	err = -ENOMEM;
> 	goto endadd2;
> }
> ...
> read_lock(...);
> ...
> 
> Rationale: Allocations are always likely to fail/succeed in close succession.
> 
> 
> Best Regards
> 
> Ingo Oeser
> 

