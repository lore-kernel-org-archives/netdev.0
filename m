From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: [RFC] sysfs + configfs on 802.11 wireless drivers
Date: Thu, 22 Jun 2006 08:12:24 -0400
Message-ID: <43e72e890606220512h5197d473s5f7da9e734814005@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"Greg KH" <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:1591 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1030627AbWFVMMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 08:12:25 -0400
Received: by ug-out-1314.google.com with SMTP id a2so447288ugf
        for <netdev@vger.kernel.org>; Thu, 22 Jun 2006 05:12:24 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rebel fleet of wireless developers,

Here's some changes which I think our current wireless stacks could
use to assist cleaning up WEs, private ioctls, and provide userspace a
cleaner framework to interact with our wireless drivers.

Kernel level:

(1) Use the new *configfs* for all user-specific attributes
(2) Use *sysfs* read-only kobjects for device-specific attributes like
values which can be saved for suspend() and collected for resume().
IEEE 802.11 capabilities, features (for example radiotap), and what is
currently settable/gettable from private ioctl realm along with its
restrictions can also be exported via sysfs.
(3) On resume() talk to userspace via netlink to read our sysfs and configfs us

Userspace applications can then:

(1) Interact with configfs for configuring wireless devices, including
what used to be set by private ioctls
(2) Retrieve attributes saved from sysfs and set them onto configfs
after resume(). Sysfs will also tell us this card's capabilities,
features and private data along with their respective restrictions we
can work with so -- userspace can modify the available options which
can be gettable/settable.
(3) Respond to netlink communication from driver after resume() to set
data through configfs

---

I know we recently moved WE to netlink but I figured celebrating the
happy marriage of Mr. sysfs and Mrs. configfs on 2.6.16 by giving them
offspring would be nice and more appropriate. Here's an example
run-through of how this would work:

(1) A wireless device comes up and spits out device-specific default
settings on sysfs

(2) If a user wants to change essid, channel, power-save-mode (this is
not suspend()), rate, and so forth userspace writes the settings into
configfs, these would in turn get updated on sysfs by the driver.

(3) Should the device go into suspend() the driver can then update its
necessary attributes on sysfs required to recover from suspend() which
may not have been updated yet (whatever they may be)

(4) At resume() we could just have our driver read our sysfs
attributes and try to set all of them back exactly how they were
before but to reduce bloat on our drivers and since our state is
already exported we could just have userspace do it for us so... we
use netlink to communicate to userspace to go ahead and ask it to
resume() us. Advantages of this would be userspace would always
consistantly handle the assoc/desassoc and WPA in a consistent manner
and as mentioned above, driver bloatness killing.

(5) At resume() userspace reads sysfs and sets us back up through configfs

Comments are appreciated, if this is something that seems desirable I
can start cranking up some code.

  Luis
