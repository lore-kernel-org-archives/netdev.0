From: <ahtraps@runbox.com>
Subject: A question on inet_select_addr()
Date: Fri, 08 Aug 2003 23:55:40 GMT
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E19lH5A-0005yt-J9@odie.runbox.com>
Reply-To: ahtraps@runbox.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
Content-Disposition: inline
To: linux-net@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I don't quite understand the comment, and the logic following it, in inet_select_addr() function.

Specifically:

1. How is it guranteed that a loopback address is not chosen? (there is no check for 127.X.X.X
    addresses!)

2. Why is it important that the loopback interface be the first in the list. What would go wrong
    if the search starts from the second device in the list (i.e., skipping the loopback device).

3. And what does this test mean: 
     (ifa->ifa_scope != RT_SCOPE_LINK && ifa->ifa_scope <= scope)?

u32 inet_select_addr(const struct net_device *dev, u32 dst, int scope)
{

        ... SNIP ...

        /* Not loopback addresses on loopback should be preferred
           in this case. It is importnat that lo is the first interface
           in dev_base list.
         */
        read_lock(&dev_base_lock);
        read_lock(&inetdev_lock);
        for (dev=dev_base; dev; dev=dev->next) {
                if ((in_dev=__in_dev_get(dev)) == NULL)
                        continue;

                read_lock(&in_dev->lock);
                for_primary_ifa(in_dev) {
                        if (ifa->ifa_scope != RT_SCOPE_LINK &&
                            ifa->ifa_scope <= scope) {
                                read_unlock(&in_dev->lock);
                                read_unlock(&inetdev_lock);
                                read_unlock(&dev_base_lock);
                                return ifa->ifa_local;
                        }
                } endfor_ifa(in_dev);
                read_unlock(&in_dev->lock);
        }
        read_unlock(&inetdev_lock);
        read_unlock(&dev_base_lock);

        return 0;
}


tx
Andy




---------------------------------------------------------------------------------------------------
Runbox Mail Manager (free trial version - this tag is removed upon subscription)
Try your own premium email account for free at http://111.runbox.com
100MB storage, no ads, fast webmail, access on any device, retrieve and filter email.
