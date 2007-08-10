From: Richard MUSIL <richard.musil@st.com>
Subject: [GENETLINK] some thoughts on the usage
Date: Fri, 10 Aug 2007 10:45:26 +0200
Message-ID: <46BC25A6.7000703@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s200aog11.obsmtp.com ([207.126.144.125]:37915 "EHLO
	s200aog11.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755490AbXHJIpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 04:45:55 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello all,

I am currently writing virtual TPM device driver. This is supposed to
behave the same way as normal TPM but instead sending commands to
hardware device, it will pass them back to user space. Probably similar
in concept to tun/tap but with the difference it has nothing to do with
networking.

I am using genetlink for communication with user space "backend".
Virtual device manager can create certain number of devices (e.g. up to
8) and it works like this:

1) Create platform device (i.e. /dev/tpm#)
2) Register genetlink family for this device with name "/dev/tpm#"
3) Register ops for this family.

I have noticed that although ops for each family are the same (each
device is functionally same) I cannot use same genl_ops struct for
registration, because it uses internal member to link in list. Therefore
it is necessary to allocate new genl_ops for each device and pass it to
registration. But I cannot "officially" use this list to track those
genl_ops (so I can properly destroy them later), because there is no
interface. So I need to redo the management of the structures on my own.

Simple function genl_get_family_ops probably would do, but I do not
know, if what I am trying to do is the intended way of using genetlink,
so I am asking first. (Can write patch for it later.)

The second "inconvenience" is that for each family I register, I also
register basically same ops (basically means, the definitions, and doit,
dumpit handlers are same, though the structures are at different
addresses for reasons described above). When the handler receives the
message it needs to associate the message with the actual device it is
handling. This could be done through family lookup (using
nlmsghdr::nlmsg_type), but I wondered if it would make sense to extend
genl_family for user custom data pointer and then pass this custom data
(or genl_family reference) to each handler (for example inside
genl_info). It is already parsed by genetlink layer, so it should not
slow things down.

What would you say?

Richard
