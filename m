From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] bonding: add sysfs /slave dir for bond slave devices.
Date: Thu, 16 Jan 2014 10:04:31 -0800
Message-ID: <B1B4CB0E-6A3C-4023-9911-D57B5F58D691@cumulusnetworks.com>
References: <20140116055434.32220.89883.stgit@monster-03.cumulusnetworks.com> <20140116153142.GD1896@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:42903 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597AbaAPSFb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 13:05:31 -0500
In-Reply-To: <20140116153142.GD1896@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jan 16, 2014, at 7:31 AM, Veaceslav Falico <vfalico@redhat.com> wrot=
e:

> On Wed, Jan 15, 2014 at 09:54:34PM -0800, Scott Feldman wrote:
>> Add sub-directory under /sys/class/net/<interface>/slave with
>> read-only attributes for slave.  Directory only appears when
>> <interface> is a slave.

>> +static ssize_t state_show(struct slave *slave, char *buf)
>> +{
>> +	switch (bond_slave_state(slave)) {
>> +	case BOND_STATE_ACTIVE:
>> +		return sprintf(buf, "active\n");
>> +	case BOND_STATE_BACKUP:
>> +		return sprintf(buf, "backup\n");
>> +	default:
>> +		return sprintf(buf, "UNKONWN\n");
>> +	}
>> +}
>> +static SLAVE_ATTR_RO(state);
>=20
> Am I missing something or does it really completely lacks any locking=
?
>=20
> What prevents the slave to be freed in between?

Correct me if I=92m wrong, but I think the equivalent question is: is t=
here a race between sysfs_remove_file() and another CPU open on that fi=
le trying to read/write the file?  I believe the answer is no, but I=92=
ll defer to the experts.

The file removal call path is:

=09
	bond_release (ndo_del_slave)
		__bond_release_one
			bond_sysfs_slave_del
				sysfs_remove_file
			<...continue freeing slave...>

So slave is freed after sysfs_remove_file.  I would expect I/O on sysfs=
 file to fail during sysfs_remove_file.

Does this sound OK?  Am I missing anything else?

-scott
		