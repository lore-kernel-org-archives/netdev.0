From: Aaron Conole <aconole@redhat.com>
Subject: Re: [PATCH -next 2/2] virtio_net: Read the advised MTU
Date: Thu, 02 Jun 2016 13:48:41 -0400
Message-ID: <f7tvb1rqy6e.fsf@redhat.com>
References: <201606030134.9z1SDe8C%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	kbuild-all@01.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: kbuild test robot <lkp@intel.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <201606030134.9z1SDe8C%fengguang.wu@intel.com> (kbuild test
	robot's message of "Fri, 3 Jun 2016 01:25:49 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


kbuild test robot <lkp@intel.com> writes:

> Hi,
>
> [auto build test ERROR on next-20160602]
>
> url:    https://github.com/0day-ci/linux/commits/Aaron-Conole/virtio-net-Advised-MTU-feature/20160603-000714
> config: i386-allmodconfig (attached as .config)
> compiler: gcc-6 (Debian 6.1.1-1) 6.1.1 20160430
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386 
>
> Note: the linux-review/Aaron-Conole/virtio-net-Advised-MTU-feature/20160603-000714 HEAD d909da4df3c52f78b4f5fcccd89aea5e38722d10 builds fine.
>       It only hurts bisectibility.
>
> All errors (new ones prefixed by >>):
>
>    drivers/net/virtio_net.c: In function 'virtnet_probe':
>>> drivers/net/virtio_net.c:1899:31: error: 'VIRTIO_NET_F_MTU'
>>> undeclared (first use in this function)
>      if (virtio_has_feature(vdev, VIRTIO_NET_F_MTU)) {
>                                   ^~~~~~~~~~~~~~~~
>    drivers/net/virtio_net.c:1899:31: note: each undeclared identifier is reported only once for each function it appears in
>    drivers/net/virtio_net.c: At top level:
>>> drivers/net/virtio_net.c:2076:2: error: 'VIRTIO_NET_F_MTU'
>>> undeclared here (not in a function)
>      VIRTIO_NET_F_MTU,
>      ^~~~~~~~~~~~~~~~

Oops, hunk was dropped during rebase.  Sorry for this, v2 will fix this
error, as well and I'll do a boot test before submission.

Thanks kbuild robot!

> vim +/VIRTIO_NET_F_MTU +1899 drivers/net/virtio_net.c
>
>   1893		    virtio_has_feature(vdev, VIRTIO_F_VERSION_1))
>   1894			vi->any_header_sg = true;
>   1895	
>   1896		if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ))
>   1897			vi->has_cvq = true;
>   1898	
>> 1899		if (virtio_has_feature(vdev, VIRTIO_NET_F_MTU)) {
>   1900			dev->mtu = virtio_cread16(vdev,
>   1901 offsetof(struct virtio_net_config,
>   1902							   mtu));
>   1903		}
>   1904	
>   1905		if (vi->any_header_sg)
>   1906			dev->needed_headroom = vi->hdr_len;
>   1907	
>   1908		/* Use single tx/rx queue pair as default */
>   1909		vi->curr_queue_pairs = 1;
>   1910		vi->max_queue_pairs = max_queue_pairs;
>   1911	
>   1912		/* Allocate/initialize the rx/tx queues, and invoke find_vqs */
>   1913		err = init_vqs(vi);
>   1914		if (err)
>   1915			goto free_stats;
>   1916	
>   1917	#ifdef CONFIG_SYSFS
>   1918		if (vi->mergeable_rx_bufs)
>   1919			dev->sysfs_rx_queue_group = &virtio_net_mrg_rx_group;
>   1920	#endif
>   1921		netif_set_real_num_tx_queues(dev, vi->curr_queue_pairs);
>   1922		netif_set_real_num_rx_queues(dev, vi->curr_queue_pairs);
>   1923	
>   1924		virtnet_init_settings(dev);
>   1925	
>   1926		err = register_netdev(dev);
>   1927		if (err) {
>   1928			pr_debug("virtio_net: registering device failed\n");
>   1929			goto free_vqs;
>   1930		}
>   1931	
>   1932		virtio_device_ready(vdev);
>   1933	
>   1934		vi->nb.notifier_call = &virtnet_cpu_callback;
>   1935		err = register_hotcpu_notifier(&vi->nb);
>   1936		if (err) {
>   1937			pr_debug("virtio_net: registering cpu notifier failed\n");
>   1938			goto free_unregister_netdev;
>   1939		}
>   1940	
>   1941		/* Assume link up if device can't report link status,
>   1942		   otherwise get link status from config. */
>   1943		if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_STATUS)) {
>   1944			netif_carrier_off(dev);
>   1945			schedule_work(&vi->config_work);
>   1946		} else {
>   1947			vi->status = VIRTIO_NET_S_LINK_UP;
>   1948			netif_carrier_on(dev);
>   1949		}
>   1950	
>   1951		pr_debug("virtnet: registered device %s with %d RX and TX vq's\n",
>   1952			 dev->name, max_queue_pairs);
>   1953	
>   1954		return 0;
>   1955	
>   1956	free_unregister_netdev:
>   1957		vi->vdev->config->reset(vdev);
>   1958	
>   1959		unregister_netdev(dev);
>   1960	free_vqs:
>   1961		cancel_delayed_work_sync(&vi->refill);
>   1962		free_receive_page_frags(vi);
>   1963		virtnet_del_vqs(vi);
>   1964	free_stats:
>   1965		free_percpu(vi->stats);
>   1966	free:
>   1967		free_netdev(dev);
>   1968		return err;
>   1969	}
>   1970	
>   1971	static void remove_vq_common(struct virtnet_info *vi)
>   1972	{
>   1973		vi->vdev->config->reset(vi->vdev);
>   1974	
>   1975		/* Free unused buffers in both send and recv, if any. */
>   1976		free_unused_bufs(vi);
>   1977	
>   1978		free_receive_bufs(vi);
>   1979	
>   1980		free_receive_page_frags(vi);
>   1981	
>   1982		virtnet_del_vqs(vi);
>   1983	}
>   1984	
>   1985	static void virtnet_remove(struct virtio_device *vdev)
>   1986	{
>   1987		struct virtnet_info *vi = vdev->priv;
>   1988	
>   1989		unregister_hotcpu_notifier(&vi->nb);
>   1990	
>   1991		/* Make sure no work handler is accessing the device. */
>   1992		flush_work(&vi->config_work);
>   1993	
>   1994		unregister_netdev(vi->dev);
>   1995	
>   1996		remove_vq_common(vi);
>   1997	
>   1998		free_percpu(vi->stats);
>   1999		free_netdev(vi->dev);
>   2000	}
>   2001	
>   2002	#ifdef CONFIG_PM_SLEEP
>   2003	static int virtnet_freeze(struct virtio_device *vdev)
>   2004	{
>   2005		struct virtnet_info *vi = vdev->priv;
>   2006		int i;
>   2007	
>   2008		unregister_hotcpu_notifier(&vi->nb);
>   2009	
>   2010		/* Make sure no work handler is accessing the device */
>   2011		flush_work(&vi->config_work);
>   2012	
>   2013		netif_device_detach(vi->dev);
>   2014		cancel_delayed_work_sync(&vi->refill);
>   2015	
>   2016		if (netif_running(vi->dev)) {
>   2017			for (i = 0; i < vi->max_queue_pairs; i++)
>   2018				napi_disable(&vi->rq[i].napi);
>   2019		}
>   2020	
>   2021		remove_vq_common(vi);
>   2022	
>   2023		return 0;
>   2024	}
>   2025	
>   2026	static int virtnet_restore(struct virtio_device *vdev)
>   2027	{
>   2028		struct virtnet_info *vi = vdev->priv;
>   2029		int err, i;
>   2030	
>   2031		err = init_vqs(vi);
>   2032		if (err)
>   2033			return err;
>   2034	
>   2035		virtio_device_ready(vdev);
>   2036	
>   2037		if (netif_running(vi->dev)) {
>   2038			for (i = 0; i < vi->curr_queue_pairs; i++)
>   2039				if (!try_fill_recv(vi, &vi->rq[i], GFP_KERNEL))
>   2040					schedule_delayed_work(&vi->refill, 0);
>   2041	
>   2042			for (i = 0; i < vi->max_queue_pairs; i++)
>   2043				virtnet_napi_enable(&vi->rq[i]);
>   2044		}
>   2045	
>   2046		netif_device_attach(vi->dev);
>   2047	
>   2048		rtnl_lock();
>   2049		virtnet_set_queues(vi, vi->curr_queue_pairs);
>   2050		rtnl_unlock();
>   2051	
>   2052		err = register_hotcpu_notifier(&vi->nb);
>   2053		if (err)
>   2054			return err;
>   2055	
>   2056		return 0;
>   2057	}
>   2058	#endif
>   2059	
>   2060	static struct virtio_device_id id_table[] = {
>   2061		{ VIRTIO_ID_NET, VIRTIO_DEV_ANY_ID },
>   2062		{ 0 },
>   2063	};
>   2064	
>   2065	static unsigned int features[] = {
>   2066		VIRTIO_NET_F_CSUM, VIRTIO_NET_F_GUEST_CSUM,
>   2067		VIRTIO_NET_F_GSO, VIRTIO_NET_F_MAC,
>   2068 VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO,
> VIRTIO_NET_F_HOST_TSO6,
>   2069 VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4,
> VIRTIO_NET_F_GUEST_TSO6,
>   2070		VIRTIO_NET_F_GUEST_ECN, VIRTIO_NET_F_GUEST_UFO,
>   2071		VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
>   2072		VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
>   2073		VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MQ,
>   2074		VIRTIO_NET_F_CTRL_MAC_ADDR,
>   2075		VIRTIO_F_ANY_LAYOUT,
>> 2076		VIRTIO_NET_F_MTU,
>   2077	};
>   2078	
>   2079	static struct virtio_driver virtio_net_driver = {
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
