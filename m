From: Marc Angel <marc@arista.com>
Subject: Re: [PATCH net-next] macvtap: add namespace support to the sysfs
 device class
Date: Thu, 28 Apr 2016 17:35:33 +0100
Message-ID: <CAPSAET_u3CYvhYgyxXdomi7n5Z6c1DTCpSMv=K544U=TjmM=cw@mail.gmail.com>
References: <1461161491-22867-1-git-send-email-marc@arista.com> <8737q933kv.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:34981 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752346AbcD1Qfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 12:35:54 -0400
Received: by mail-ob0-f175.google.com with SMTP id n10so36714993obb.2
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 09:35:53 -0700 (PDT)
In-Reply-To: <8737q933kv.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 25, 2016 at 8:12 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>> The 'net' device class is isolated between network namespaces so each
>> one has its own hierarchy of net devices.
>> This isn't the case for the 'macvtap' device class.
>> The problem occurs half-way through the netdev registration, when
>> `macvtap_device_event` is called-back to create the 'tapNN' macvtap
>> class device under the 'macvtapX' net class device.
>>
>> This patch adds namespace support the the 'macvtap' device class so
>> that /sys/class/macvtap is no longer shared between net namespaces.
>>
>> However, doing this has the side effect of changing
>> /sys/devices/virtual/net/macvtapX/tapNN  into
>> /sys/devices/virtual/net/macvtapX/macvtap/tapNN
>
> I forget the details of how this interface works, but
> /sys/devices/virtual/net is definitely allows different overlapping
> content per network namespace, so we should not need to add an extra
> directory to make this work.

It really seems like we do, unfortunately.

For a kernfs_node to have the KERNFS_NS flag enabled, sysfs_enable_ns
has to be called on it. This is only done in the create_dir function of
lib/kobject.c, and only when the parent of that kobject has a ktype with
the child_ns_type field set to something.

This is the case for class_dir_ktype which is the type used for the
"glue" dirs (the extra macvtap/ that is created under macvtapX).
This, however, is not the case for device_ktype, which is the type
used for every device directory.
When we create tapN directly under macvtapX, tapN doesn't get the
KERNFS_NS flag enabled -- unlike when created under the "glue" dir.

This is problematic when creating the following symlink:
/sys/class/macvtap/tapN -> /sys/devices/virtual/net/macvtapX/tapN.
The tapN in /sys/class/macvtap inherits the namespace tag from
/sys/devices/virtual/net/macvtapX/tapN, which doesn't have one anymore
and kernfs_add_one fails because it expects it to.

Adding a child_ns_type field to device_ktype is probably not a good idea
and seems to cause other problems.

The best workaround is probably to just create a symlink inside the
macvtapX device directory (tapN -> macvtap/tapN).

I'll update my patch accordingly if you don't have a better idea.

>> Should it even be possible to add a device of a class that doesn't
>> support namespaces under one that does?
>> This could lead to dead symlinks in the new device class directory or
>> duplicate warnings because a device of the same name already exists in
>> another namespace.
>
> This definitely looks like something that bears digging into, and fixing
> properly.
>
> Eric
