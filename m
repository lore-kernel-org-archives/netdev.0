From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCHv3 net-next 1/3] sunvnet: upgrade to VIO protocol version
 1.6
Date: Sat, 13 Sep 2014 22:39:25 -0400
Message-ID: <5414FFDD.9050509@oracle.com>
References: <54146A42.1050703@oracle.com> <20140913.161842.2265200935397549583.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:32342 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752288AbaINCjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 22:39:32 -0400
In-Reply-To: <20140913.161842.2265200935397549583.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/13/2014 04:18 PM, David Miller wrote:
> From: David L Stevens <david.stevens@oracle.com>

> Is this really applicable to devices other than sunvnet?  Just keep
> this attribute in the sunvnet driver "struct vnet_port" private state.

Yes, I'll move it.

> 
>> +	/* v1.6 and higher, ACK with desired, supported mode, or NACK */
>> +	if (vio->ver.major <= 1 && vio->ver.minor >= 6) {
>  ...
>> +	if (vio->ver.major <= 1 && vio->ver.minor < 2)
>  ...
>> +	/* for version < 1.2, VIO_DRING_MODE = 0x3 and no bitmask */
>> +	if ((vio->ver.major <= 1 &&  vio->ver.minor < 2) &&
> ...
>> +	if (vio->ver.major == 1 && vio->ver.minor < 3) {
> 	...
>> +	} else if (vio->ver.major == 1 && vio->ver.minor == 3) {
> 	...
>> +	} else {
> 	...
>> +	}
>  ...
>> +	/* for version >= 1.6, ACK packet mode we support */
>> +	if (vio->ver.major <= 1 && vio->ver.minor >= 6) {
> 
> These version tests give me a headache, and some of them accept
> impossible things like major version zero.  If we only have major
> version 1 and later in our version lists, testing things like "major
> <= 1" makes no sense at all.
> 
> That last test quoted above definitely looks wrong, it should
> be testing "major >= 1" if anything if it is trying to test
> "version >= 1.6"

Yes, that'd break at > v2.0 -- good catch.

> Sadly, I expect that we'll have more and more of these version tests
> over time.  So why not make some generic helpers in the VIO or LDC
> layer?
> 
> static inline bool vio_version_before(struct vio_driver_state *vio,
> 				      u16 major, u16 minor)
> {
> 	u32 have = (u32)vio->major << 16 | vio->minor;
> 	u32 want = (u32)major << 16 | minor;
> 
> 	return have < want;
> }
> static inline bool vio_version_after_eq(struct vio_driver_state *vio,
> 					u16 major, u16 minor)
> {
> 	u32 have = (u32)vio->major << 16 | vio->minor;
> 	u32 want = (u32)major << 16 | minor;
> 
> 	return have >= want;
> }
> 
> Something like that.

Sure. I was thinking about something like:

#define VIO_VER(major, minor)	(((major)<<16)|(minor))

change the version struct to a 32-bit int, and do things like:

	if (vio->ver > VIO_VER(1,6)) {

unless you have a preference. (?)

						+-DLS
