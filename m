From: cndougla@linux.vnet.ibm.com
Subject: SUSv3 recvmsg, sendmsg compliance
Date: Tue,  4 Aug 2009 10:14:11 -0400
Message-ID: <20090804101411.y5fmtgh2skwkw4gc@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	DelSp=Yes	format=flowed
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:59763 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752490AbZHDOO2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 10:14:28 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e38.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n74EAvjo027714
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 08:10:57 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n74EEIkh216952
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 08:14:20 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n74EEHXP003813
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 08:14:17 -0600
Received: from linux.ibm.com (imap.raleigh.ibm.com [9.37.253.145])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id n74EEGho003658
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 08:14:16 -0600
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While running the LSB testsuite I noticed that on ppc 32-bit  
userland/64-bit kernel recvmsg returned EPERM (-1) instead of EMSGSIZE  
in errno when the sole iovec's iov_len was set to -1. According to the  
SUSv3 standard, iov_len must be positive and less than IOV_MAX:

http://www.opengroup.org/onlinepubs/000095399/functions/recvmsg.html

In Linux, iov_len is defined as an unsigned value. This does not seem  
to be forbidden by the standard, so that means we can't trip EMSGSIZE  
just by setting iov_len to -1. However, Linux also doesn't have  
IOV_MAX. In fact, Linux doesn't care how big you set iov_len since in  
memcpy_toiovec() the size is bounded by the size of the packet being  
copied:

                if (iov->iov_len) {
                        int copy = min_t(unsigned int, iov->iov_len, len);
                        if (copy_to_user(iov->iov_base, kdata, copy))
                                return -EFAULT;
                        kdata += copy;
                        len -= copy;
                        iov->iov_len -= copy;
                        iov->iov_base += copy;
                }
                iov++;

So far, it looks like Linux is compliant to SUSv3 because it handles  
all iov_len passed in. However, before we get to memcpy_toiovec(),  
verify_iovec() or verify_compat_iovec() are called. These functions  
don't really do any verification of arguments from user-space.  
Instead, they merely copy them to kernel-space and determine the total  
length requested by adding up all the iovec iov_len sizes.  
Unfortunately, the return value is used both for error checking and  
for returning the total length. Thus, if the total length overflows a  
signed integer the functions will return an error. This is where  
verify_iovec() and verify_compat_iovec() differ. In verify_iovec(), if  
the total length is negative at any point, the function returns  
-EMSGSIZE:

        int err;
<snip>
        for (ct = 0; ct < m->msg_iovlen; ct++) {
                err += iov[ct].iov_len;
                /*
                 * Goal is not to verify user data, but to prevent returning
                 * negative value, which is interpreted as errno.
                 * Overflow is still possible, but it is harmless.
                 */
                if (err < 0)
                        return -EMSGSIZE;
        }

In verify_compat_iovec(), the total size is returned no matter what,  
and it doesn't return -EMSGSIZE if the total size is negative:

        int tot_len = 0;

        while (niov > 0) {
                compat_uptr_t buf;
                compat_size_t len;

                if (get_user(len, &uiov32->iov_len) ||
                   get_user(buf, &uiov32->iov_base)) {
                        tot_len = -EFAULT;
                        break;
                }
                tot_len += len;
                kiov->iov_base = compat_ptr(buf);
                kiov->iov_len = (__kernel_size_t) len;
                uiov32++;
                kiov++;
                niov--;
        }
        return tot_len;

The returned value from verify_compat_iovec() is then passed back to  
userspace. This explains why I received EPERM (-1) when I set iov_len  
to -1. This breaks SUSv3 compliance. Any issues with iov_len should  
set errno to EMSGSIZE.

Also, verify_iovec() can be defeated by using iov_lens of 2 and -1,  
and verify_iovec_compat() can be defeated by using the same values or  
the same values swapped in order.

A correct solution to this issue would be to save the total length in  
a variable passed by reference into verify*iovec(), and return 0 on  
success or an errno if the total length overflows. The total length  
could then be saved as a size_t, which doubles the total amount able  
to be received due to its unsigned nature.

Before I work up a patch and test it, I would like some feedback as to  
whether this approach is acceptable for upstream.

Thanks,
Chase Douglas

