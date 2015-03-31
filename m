From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 02/18] switchdev: flesh out get/set attr ops
Date: Mon, 30 Mar 2015 17:38:31 -0700
Message-ID: <CAE4R7bA4qBk2mXa=A3fg=j+c-w6cHPYhPHVkdhJo=LUW4FX7YA@mail.gmail.com>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
	<1427704836-8776-3-git-send-email-sfeldma@gmail.com>
	<E4CD12F19ABA0C4D8729E087A761DC35067FAA25@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jiri@resnulli.us" <jiri@resnulli.us>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"linux@roeck-us.net" <linux@roeck-us.net>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:33754 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753851AbbCaAic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 20:38:32 -0400
Received: by obvd1 with SMTP id d1so3249851obv.0
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 17:38:31 -0700 (PDT)
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC35067FAA25@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 30, 2015 at 5:22 PM, Arad, Ronen <ronen.arad@intel.com> wrote:
>
>
>>-----Original Message-----
>>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>>Behalf Of sfeldma@gmail.com
>>Sent: Monday, March 30, 2015 1:40 AM
>>To: netdev@vger.kernel.org
>>Cc: jiri@resnulli.us; roopa@cumulusnetworks.com; linux@roeck-us.net;
>>f.fainelli@gmail.com
>>Subject: [PATCH net-next 02/18] switchdev: flesh out get/set attr ops
>>
>>From: Scott Feldman <sfeldma@gmail.com>
>>
> [cut]
>>
>> int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
>> {
>>-      return -EOPNOTSUPP;
>>+      struct swdev_attr prev = *attr;
>>+      int err, get_err;
>>+
>>+      get_err = swdev_port_attr_get(dev, &prev);
>>+
>>+      err = _swdev_port_attr_set(dev, attr);
>>+      if (err && !get_err && !(attr->flags & SWDEV_ATTR_F_NO_RECOVER))
>>+              /* Some err on set: revert to previous value */
>>+              _swdev_port_attr_set(dev, &prev);
>
> Netlink requests could contain multiple attributes within a single request.
> Reverting to the previous value applies only to the first
> swdev_port_attr_set error. It does not rollback all prior changes that
> were triggered by the same Netlink request.

Since attr_set scope is a single attr across ports, it can only revert
that attr for those ports.  So rewinding multiple attributes needs to
happen above attr_set.  I guess we could have a multi_attr_set that
takes an array of *attrs, but something like this can be built on top
of attr_set.  Maybe baby steps is best first so we can see how things
shape up.
