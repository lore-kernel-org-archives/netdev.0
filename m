From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/4] RFC: raw IPv6 address parsing in NFS client
Date: Mon, 19 May 2008 15:46:11 -0400
Message-ID: <7799EF8C-6BDB-4B32-ABD8-E3DF840D5195@oracle.com>
References: <20080518210625.13450.71349.stgit@ellison.1015granger.net> <4830E24C.3020405@garzik.org> <BA7B3AE0-E0BA-4535-8641-5DC4A3A41F64@oracle.com> <4831CD54.9050004@garzik.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:16170 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756914AbYESTvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 15:51:40 -0400
In-Reply-To: <4831CD54.9050004@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On May 19, 2008, at 2:56 PM, Jeff Garzik wrote:
> Chuck Lever wrote:
>> On May 18, 2008, at 10:13 PM, Jeff Garzik wrote:
>>> Chuck Lever wrote:
>>>> Hi-
>>>> I'm interested in some review of the following four patches which  
>>>> add to
>>>> the kernel's NFS client the ability to parse IPv6 addresses in  
>>>> presentation
>>>> format.
>>>> Namely, it adds the following:
>>>> 1.  If the user passes in an IPv6 address as the server name, the  
>>>> colons
>>>>   in the address will confuse the logic that splits the device name
>>>>   into a server hostname and an export path.   We'll use square  
>>>> brackets
>>>>   around IPv6 server addresses to "escape" the colons, as does  
>>>> Solaris.
>>>> 2.  If the user passes in a link-local IPv6 address as the server  
>>>> name,
>>>>   an interface index is also necessary.  We'll use the "%id"  
>>>> suffix on
>>>>   the address to pass in the index, and plant that in the  
>>>> sockaddr's
>>>>   sin6_scope_id field.
>>>> In addition to the following patches in email, a git repo with  
>>>> these
>>>> same patches already applied can be found here:
>>>>    linux-nfs.org:exports/cel-2.6.git
>>>> The basic questions:
>>>> Are these reasonable conventions to follow?  Is the parsing logic  
>>>> adequate?
>>>> Is there anything I'm forgetting?
>>>
>>> I would take a look at the underlying components of glibc's  
>>> getnameinfo(), which must parse IPv6 addresses according to POSIX  
>>> specifications, IIRC.
>>>
>>> Comments:
>>>
>>> 1) bracket escaping seems reasonably common.  browsers and other  
>>> apps sometimes use that convention too.
>>>
>>> 2) an interface name rather than index should be used
>> If you give a raw IPv6 address with an interface name to mount.nfs,  
>> it passes the whole thing to getaddrinfo(3) which maps the name to  
>> an index. The address with index is then passed on to the kernel  
>> via mount(2) via the normal "addr=" mount option.
>> Is there a way the kernel can do that mapping for itself?
>
> The kernel certainly knows the interface names...  IMO that is a bit  
> more natural than interface index.
>
> You certainly do not want to _store_ interface index or encourage  
> its use, since it might change during runtime if network interfaces  
> change.

We are storing the address of the server in a struct sockaddr_storage,  
and that would include a scope ID if it were an AF_INET6 address.  We  
are also storing the server hostname in /etc/mtab for umount.nfs to  
use later, and that hostname may be a raw IPv6 address.

So it sounds like we need to store the device name separately in the  
kernel's NFS and RPC data structures and do the devname to scope_id  
conversion during the transport's socket connect.  Oy.

> I don't know precisely your intended usage, nor where your kernel/ 
> userland divide is here, but looking at dev_get_by_name() might be a  
> start, for accessing netdev via ifname?

Yes, the NFS client (or RPC client) could invoke that as long as it is  
always built-in and not a module.

The mount.nfs command always passes the incoming server hostname  
through getaddrinfo(3).  If the hostname is an IPv6 address with  
either a device name or an interface index, getaddrinfo() does set the  
sin6_scope_id field in the resulting sockaddr.

That sockaddr is used to generate a presentation format address string  
to pass to the kernel.  mount.nfs then should always convert the scope  
ID back to a device name at that point, and the kernel should assume  
if a SCOPE_DELIMITER is present, the thing that follows it is always a  
device name.

Since the interface index isn't directly exposed in Linux user space  
anyway, as it is on Solaris (via ifconfig) perhaps it's worth it to  
limit the NFS mount interface to network device names only.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
