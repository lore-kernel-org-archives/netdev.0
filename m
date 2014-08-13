From: Cong Wang <cwang@twopensource.com>
Subject: Re: null pointer dereference caused by a188a54d1162 ("macvlan:
 simplify the structure port")
Date: Wed, 13 Aug 2014 16:00:39 -0700
Message-ID: <CAHA+R7NO3agW8QoSQh7h=ewU6siNgC_T0h-0Kem+vxFDhPeyQA@mail.gmail.com>
References: <1407967062.28924.33.camel@jekeller-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dingtianhong@huawei.com" <dingtianhong@huawei.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:35758 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752830AbaHMXAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 19:00:41 -0400
Received: by mail-lb0-f181.google.com with SMTP id 10so350143lbg.12
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2014 16:00:40 -0700 (PDT)
In-Reply-To: <1407967062.28924.33.camel@jekeller-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 13, 2014 at 2:57 PM, Keller, Jacob E
<jacob.e.keller@intel.com> wrote:
> Hello,
>
> I found a null pointer dereference caused by instantiating multiple
> macvlans on a single parent port device. Below is a copy of the NULL
> pointer dereference stack dump.
>
[...]
>
> This was done on the head of net tree with the offending patch reverted,
> but I also added in a trace_printk to show when the macvlan port was
> empty via the list_head vlans parameter. As you can see above, the
> macvlan_uninit is called multiple, but only after the dellink has been
> called. We call list_del on the vlan item in macvlan_dellink, but then
> we later call macvlan_uninit for each item. Because we deleted the item
> from the list in macvlan_dellink, the list is already emptied completely
> by the time we call macvlan_uninit. In the bugged case, we would have
> ended up calling macvlan_port_destroy for each macvlan we created. (Four
> in my scenario above.)
>
> I think a possible fix besides simply reverting the patch might be to
> move the list_del into the macvlan_uninit. This is the same place we
> originally decremented the count, so thus makes more sense than doing
> the list_del in the macvlan_dellink function.
>
> Hopefully the above provided information is enough to determine a good
> solution to resolve the issue. My opinion is that either the above
> list_del fix or simply reverting this patch is enough.

Or just checking against NULL before calling macvlan_port_destroy().
But that will make the first macvlan_uninit() free the port instead of the
last one. I don't know, I'd vote to just revert that commit, it brings nothing
but a bug.
